import { Router } from 'express';
import prisma from '../../shared/database/prisma.js';
import { authMiddleware } from '../../shared/middlewares/auth.middleware.js';
import type { AuthRequest } from '../../shared/middlewares/auth.middleware.js';

const router = Router();

// Get user profile
router.get('/profile', authMiddleware, async (req: AuthRequest, res) => {
  const userId = req.user?.id;
  if (!userId) return res.status(401).json({ message: 'Unauthorized' });
  try {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        name: true,
        phone: true,
        role: true,
        createdAt: true,
        addresses: true
      }
    });
    res.json(user);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching profile' });
  }
});

// Update profile
router.patch('/profile', authMiddleware, async (req: AuthRequest, res) => {
  const userId = req.user?.id;
  if (!userId) return res.status(401).json({ message: 'Unauthorized' });
  
  const { name, phone } = req.body;
  try {
    const user = await prisma.user.update({
      where: { id: userId },
      data: { name, phone },
      select: {
        id: true,
        email: true,
        name: true,
        phone: true,
        role: true
      }
    });
    res.json(user);
  } catch (error) {
    res.status(500).json({ message: 'Error updating profile' });
  }
});

// Add/Update address
router.post('/address', authMiddleware, async (req: AuthRequest, res) => {
  const userId = req.user?.id;
  const { street, city, state, zipCode, country, isDefault } = req.body;
  
  if (!userId) return res.status(401).json({ message: 'Unauthorized' });

  try {
    const address = await prisma.address.create({
      data: { userId, street, city, state, zipCode, country, isDefault }
    });
    res.status(201).json(address);
  } catch (error) {
    res.status(500).json({ message: 'Error saving address' });
  }
});

// Delete address
router.delete('/address/:id', authMiddleware, async (req: AuthRequest, res) => {
  const userId = req.user?.id;
  if (!userId) return res.status(401).json({ message: 'Unauthorized' });

  try {
    await prisma.address.delete({
      where: { id: req.params.id as string, userId }
    });
    res.json({ message: 'Address deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting address' });
  }
});

export default router;
