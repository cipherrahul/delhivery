import { Router } from 'express';
import { PrismaClient } from '@prisma/client';
import { io } from '../../app.js';

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

export default router;
