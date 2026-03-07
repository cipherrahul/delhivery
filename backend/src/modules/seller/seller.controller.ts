import { Router } from 'express';
import { authMiddleware, roleGuard } from '../../shared/middlewares/auth.middleware.js';
import type { AuthRequest } from '../../shared/middlewares/auth.middleware.js';
import prisma from '../../shared/database/prisma.js';

const router = Router();

// Get seller profile & dashboard stats
router.get('/dashboard', authMiddleware, roleGuard(['SELLER']), async (req: AuthRequest, res) => {
  const userId = req.user?.id;
  if (!userId) return res.status(401).json({ message: 'Unauthorized' });
  
  try {
    const seller = await prisma.seller.findUnique({
      where: { userId },
      include: { 
        products: true,
        _count: { select: { products: true } }
      }
    });

    if (!seller) return res.status(404).json({ message: 'Seller profile not found' });

    // Fetch order items for this seller's products
    const orders = await prisma.orderItem.findMany({
      where: { product: { sellerId: seller.id } },
      include: { order: true }
    });

    // Granular stats
    const totalOrders = orders.length;
    const totalRevenue = orders.reduce((sum: number, item: any) => sum + (item.price * item.quantity), 0);
    const lowStockCount = seller.products.filter((p: any) => p.stock < 5).length;
    
    // Average rating
    const reviews = await prisma.review.findMany({
      where: { product: { sellerId: seller.id } }
    });
    
    const avgRating = reviews.length > 0 
      ? reviews.reduce((sum: number, r: any) => sum + r.rating, 0) / reviews.length 
      : 4.8; // Default for new sellers

    res.json({ 
      seller, 
      stats: {
        totalOrders,
        totalRevenue,
        lowStockCount,
        avgRating: parseFloat(avgRating.toFixed(1)),
        activeProducts: seller._count.products
      }
    });
  } catch (error) {
    console.error('Dashboard Error:', error);
    res.status(500).json({ message: 'Error fetching dashboard' });
  }
});

// Get seller products
router.get('/products', authMiddleware, roleGuard(['SELLER']), async (req: AuthRequest, res) => {
  const userId = req.user?.id;
  if (!userId) return res.status(401).json({ message: 'Unauthorized' });
  try {
    const products = await prisma.product.findMany({
      where: { seller: { userId } }
    });
    res.json(products);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching products' });
  }
});

export default router;
