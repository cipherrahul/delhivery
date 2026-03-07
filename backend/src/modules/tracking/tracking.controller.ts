import { Router } from 'express';
import { PrismaClient, Prisma } from '@prisma/client';
import { io } from '../../app.js';
import { authMiddleware, roleGuard } from '../../shared/middlewares/auth.middleware.js';

const router = Router();
const prisma = new PrismaClient();

// Update driver location (Real-time)
router.post('/location', async (req, res) => {
  const { driverId, lat, lng, shipmentId } = req.body;
  try {
    // Update DB
    await prisma.driver.update({
      where: { id: driverId },
      data: { lat, lng }
    });

    // Broadcast via Socket.io
    io.of('/tracking').emit(`locationUpdate:${shipmentId}`, { lat, lng, timestamp: new Date() });

    res.json({ message: 'Location updated and broadcasted' });
  } catch (error) {
    res.status(500).json({ message: 'Error updating location' });
  }
});

// Get tracking history
router.get('/:shipmentId', async (req, res) => {
  const { shipmentId } = req.params;
  try {
    const shipment = await prisma.shipment.findUnique({
      where: { id: shipmentId },
      include: { events: true, driver: true }
    });
    res.json(shipment);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching tracking' });
  }
});

// Update shipment status (Admin or Seller or Driver)
router.patch('/:shipmentId/status', authMiddleware, roleGuard(['ADMIN', 'SELLER', 'DRIVER']), async (req, res) => {
  const { shipmentId } = req.params;
  const { status, location } = req.body;
  
  try {
    const result = await prisma.$transaction(async (tx: any) => {
      // 1. Update Shipment status
      const shipment = await tx.shipment.update({
        where: { id: shipmentId as string },
        data: { status: status as string }
      });

      // 2. Update Order status if shipment is DELIVERED
      if (status === 'DELIVERED') {
        await tx.order.update({
          where: { id: shipment.orderId },
          data: { status: 'DELIVERED' }
        });
      }

      // 3. Record tracking event
      await tx.trackingEvent.create({
        data: {
          shipmentId,
          status,
          location: location || 'Warehouse'
        }
      });

      return shipment;
    });

    // 4. Emit real-time notification
    io.of('/tracking').emit(`orderStatusUpdate:${result.orderId}`, {
      status: result.status,
      timestamp: new Date()
    });

    res.json(result);
  } catch (error) {
    res.status(500).json({ message: 'Error updating shipment status' });
  }
});

export default router;
