import { Router } from 'express';
import { PrismaClient } from '@prisma/client';

const router = Router();
const prisma = new PrismaClient();

// Add review
router.post('/', async (req, res) => {
  const { productId, userId, rating, comment } = req.body;
  try {
    const review = await prisma.review.create({
      data: { productId, userId, rating, comment }
    });
    res.status(201).json(review);
  } catch (error) {
    res.status(500).json({ message: 'Error adding review' });
  }
});

export default router;
