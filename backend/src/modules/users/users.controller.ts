import { Router } from 'express';
import { PrismaClient } from '@prisma/client';
import { authMiddleware } from '../../shared/middlewares/auth.middleware.js';
import type { AuthRequest } from '../../shared/middlewares/auth.middleware.js';

const router = Router();
const prisma = new PrismaClient();

// Get user profile
router.get('/profile', authMiddleware, async (req: AuthRequest, res) => {
  const userId = req.user?.id;
  if (!userId) return res.status(401).json({ message: 'Unauthorized' });
  try {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: { addresses: true }
    });
    res.json(user);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching profile' });
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

export default router;
