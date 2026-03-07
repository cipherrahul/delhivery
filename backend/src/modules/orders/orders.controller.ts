import { Router } from 'express';
import prisma from '../../shared/database/prisma.js';
import { authMiddleware } from '../../shared/middlewares/auth.middleware.js';
import { z } from 'zod';
import type { AuthRequest } from '../../shared/middlewares/auth.middleware.js';

const router = Router();

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
          },
          shipment: {
            create: {
              trackingNumber: `DLV-${Math.random().toString(36).substring(2, 11).toUpperCase()}`,
              status: 'PICKED_UP'
            }
          }
        },
        include: { items: true, payment: true, shipment: true }
      });

      // 3. Clear cart
      await tx.cartItem.deleteMany({
        where: { userId }
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

// Cancel an order (Customer)
router.post('/:id/cancel', authMiddleware, async (req: AuthRequest, res) => {
  const userId = req.user?.id;
  if (!userId) return res.status(401).json({ message: 'Unauthorized' });

  try {
    const result = await prisma.$transaction(async (tx: any) => {
      const order = await tx.order.findUnique({
        where: { id: req.params.id as string },
        include: { items: true }
      });

      if (!order || order.userId !== userId) throw new Error('Order not found');
      if (order.status !== 'PENDING') throw new Error('Only pending orders can be cancelled');

      // 1. Restore stock
      for (const item of order.items) {
        await tx.product.update({
          where: { id: item.productId },
          data: { stock: { increment: item.quantity } }
        });
      }

      // 2. Update order status
      const updatedOrder = await tx.order.update({
        where: { id: req.params.id as string },
        data: { status: 'CANCELLED' }
      });

      // 3. Update shipment status if exists
      await tx.shipment.updateMany({
        where: { orderId: order.id },
        data: { status: 'CANCELLED' }
      });

      return updatedOrder;
    });

    res.json({ message: 'Order cancelled successfully', order: result });
  } catch (error: any) {
    res.status(400).json({ message: error.message || 'Error cancelling order' });
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

// Request a return (Customer)
router.post('/:id/return', authMiddleware, async (req: AuthRequest, res) => {
  const userId = req.user?.id;
  if (!userId) return res.status(401).json({ message: 'Unauthorized' });

  const { reason } = req.body;

  try {
    const order = await prisma.order.findUnique({
      where: { id: req.params.id as string },
    });

    if (!order || order.userId !== userId) return res.status(404).json({ message: 'Order not found' });
    if (order.status !== 'DELIVERED') return res.status(400).json({ message: 'Only delivered orders can be returned' });

    const updatedOrder = await prisma.order.update({
      where: { id: req.params.id as string },
      data: { status: 'RETURN_REQUESTED' }
    });

    res.json({ message: 'Return requested successfully', order: updatedOrder });
  } catch (error) {
    res.status(500).json({ message: 'Error requesting return' });
  }
});

export default router;
