import { Router } from 'express';
import prisma from '../../shared/database/prisma.js';
import { authMiddleware, type AuthRequest } from '../../shared/middlewares/auth.middleware.js';
import { z } from 'zod';

const router = Router();

const reviewSchema = z.object({
  productId: z.string().uuid(),
  rating: z.number().int().min(1).max(5),
  comment: z.string().optional(),
});

// Add review
router.post('/', authMiddleware, async (req: AuthRequest, res) => {
  try {
    const { productId, rating, comment } = reviewSchema.parse(req.body);
    const userId = req.user?.id;
    
    if (!userId) return res.status(401).json({ message: 'Unauthorized' });

    const review = await prisma.review.upsert({
      where: { productId_userId: { productId, userId } },
      update: { rating, comment: comment ?? null },
      create: { productId, userId, rating, comment: comment ?? null }
    });
    res.status(201).json(review);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ errors: error.issues });
    }
    res.status(500).json({ message: 'Error adding review' });
  }
});

// Get reviews for a product
router.get('/product/:productId', async (req, res) => {
  const { productId } = req.params;
  try {
    const reviews = await prisma.review.findMany({
      where: { productId },
      include: { user: { select: { name: true } } },
      orderBy: { createdAt: 'desc' }
    });
    res.json(reviews);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching reviews' });
  }
});

export default router;
