import { Router } from 'express';
import { PrismaClient } from '@prisma/client';
import { authMiddleware, AuthRequest } from '../../shared/middlewares/auth.middleware.js';
import { z } from 'zod';

const router = Router();
const prisma = new PrismaClient();

const cartSchema = z.object({
  productId: z.string().uuid(),
  quantity: z.number().int().positive().optional(),
});

// Get cart items
router.get('/', authMiddleware, async (req: AuthRequest, res) => {
  const userId = req.user?.id;
  try {
    const cart = await prisma.cartItem.findMany({
      where: { userId },
      include: { product: true }
    });
    res.json(cart);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching cart' });
  }
});

// Add to cart
router.post('/', authMiddleware, async (req: AuthRequest, res) => {
  const userId = req.user?.id;
  try {
    const { productId, quantity } = cartSchema.parse(req.body);
    const cartItem = await prisma.cartItem.upsert({
      where: { userId_productId: { userId: userId!, productId } },
      update: { quantity: { increment: quantity || 1 } },
      create: { userId: userId!, productId, quantity: quantity || 1 }
    });
    res.status(201).json(cartItem);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ errors: error.issues });
    }
    res.status(500).json({ message: 'Error adding to cart' });
  }
});

export default router;
