import { Router } from 'express';
import { PrismaClient } from '@prisma/client';
import { authMiddleware } from '../../shared/middlewares/auth.middleware.js';
import { z } from 'zod';
import type { AuthRequest } from '../../shared/middlewares/auth.middleware.js';

const router = Router();
const prisma = new PrismaClient();

const orderSchema = z.object({
  items: z.array(z.object({
    productId: z.string().uuid(),
    quantity: z.number().int().positive(),
    price: z.number().positive(),
  })).min(1),
  total: z.number().positive(),
});

// Place an order
router.post('/', authMiddleware, async (req: AuthRequest, res) => {
  try {
    const { items, total } = orderSchema.parse(req.body);
    const userId = req.user?.id;

    if (!userId) return res.status(401).json({ message: 'Unauthorized' });

    const result = await prisma.$transaction(async (tx: any) => {
      // 1. Check and update stock
      for (const item of items) {
        const product = await tx.product.findUnique({ where: { id: item.productId } });
        if (!product || product.stock < item.quantity) {
          throw new Error(`Insufficient stock for product: ${product?.name || item.productId}`);
        }
        await tx.product.update({
          where: { id: item.productId },
          data: { stock: { decrement: item.quantity } }
        });
      }

      // 2. Create order
      const order = await tx.order.create({
        data: {
          userId,
          total,
          status: 'PENDING',
          items: {
            create: items.map((item: any) => ({
              productId: item.productId,
              quantity: item.quantity,
              price: item.price
            }))
          },
          payment: {
            create: {
              amount: total,
              method: 'COD', // Default for now
              status: 'PENDING'
            }
          }
        },
        include: { items: true, payment: true }
      });

      return order;
    });

    res.status(201).json(result);
  } catch (error: any) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ errors: error.issues });
    }
    res.status(400).json({ message: error.message || 'Error placing order' });
  }
});

// Get user orders
router.get('/', authMiddleware, async (req: AuthRequest, res) => {
  const userId = req.user?.id;
  if (!userId) return res.status(401).json({ message: 'Unauthorized' });
  try {
    const orders = await prisma.order.findMany({
      where: { userId },
      include: { items: { include: { product: true } }, shipment: true, payment: true }
    });
    res.json(orders);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching orders' });
  }
});

export default router;
