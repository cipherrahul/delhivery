import { Router } from 'express';
import { PrismaClient } from '@prisma/client';

const router = Router();
const prisma = new PrismaClient();

// Create payment
router.post('/', async (req, res) => {
  const { orderId, amount, method } = req.body;
  try {
    const payment = await prisma.payment.create({
      data: { orderId, amount, method, status: 'PENDING' }
    });
    res.status(201).json(payment);
  } catch (error) {
    res.status(500).json({ message: 'Error processing payment' });
  }
});

export default router;
