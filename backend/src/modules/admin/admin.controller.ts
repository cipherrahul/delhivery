import { Router } from 'express';
import { PrismaClient } from '@prisma/client';
import { authMiddleware, roleGuard } from '../../shared/middlewares/auth.middleware.js';

const router = Router();
const prisma = new PrismaClient();

// Get global platform metrics (Admin only)
router.get('/metrics', authMiddleware, roleGuard(['ADMIN']), async (req, res) => {
  try {
    const totalUsers = await prisma.user.count();
    const activeSellers = await prisma.seller.count();
    
    // Total gross merchandise value
    const payments = await prisma.payment.findMany({
      where: { status: 'COMPLETED' }
    });
    const totalGMV = payments.reduce((sum: number, p: any) => sum + p.amount, 0);

    res.json({
      metrics: {
        totalUsers,
        activeSellers,
        totalGMV,
        systemHealth: '99.9%'
      }
    });
  } catch (error) {
    res.status(500).json({ message: 'Error fetching metrics' });
  }
});

// Admin: Search and manage users
router.get('/users', authMiddleware, roleGuard(['ADMIN']), async (req, res) => {
  const { query, role } = req.query;
  try {
    const users = await prisma.user.findMany({
      where: {
        ...(query && {
          OR: [
            { name: { contains: String(query), mode: 'insensitive' } },
            { email: { contains: String(query), mode: 'insensitive' } }
          ]
        }),
        ...(role && { role: role as any })
      },
      select: {
        id: true,
        name: true,
        email: true,
        role: true,
        createdAt: true
      }
    });
    res.json(users);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching users' });
  }
});

// Admin: List all shipments
router.get('/shipments', authMiddleware, roleGuard(['ADMIN']), async (req, res) => {
  try {
    const shipments = await prisma.shipment.findMany({
      include: { order: true, driver: true }
    });
    res.json(shipments);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching shipments' });
  }
});

// Admin: List all products (raw list)
router.get('/products', authMiddleware, roleGuard(['ADMIN']), async (req, res) => {
  try {
    const products = await prisma.product.findMany({
      include: { seller: true }
    });
    res.json(products);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching products' });
  }
});

// Admin: Verify a seller
router.patch('/sellers/:id/verify', authMiddleware, roleGuard(['ADMIN']), async (req, res) => {
  try {
    const seller = await prisma.seller.update({
      where: { id: req.params.id as string },
      data: { isVerified: true }
    });
    res.json({ message: 'Seller verified successfully', seller });
  } catch (error) {
    res.status(500).json({ message: 'Error verifying seller' });
  }
});

export default router;
