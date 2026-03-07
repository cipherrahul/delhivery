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

export default router;
