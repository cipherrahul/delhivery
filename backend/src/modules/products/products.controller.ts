import { Router } from 'express';
import { PrismaClient } from '@prisma/client';
import { authMiddleware, roleGuard } from '../../shared/middlewares/auth.middleware.js';
import type { AuthRequest } from '../../shared/middlewares/auth.middleware.js';
import { z } from 'zod';

const router = Router();
const prisma = new PrismaClient();

const productSchema = z.object({
  name: z.string().min(3),
  description: z.string().min(10),
  price: z.number().positive(),
  stock: z.number().int().nonnegative(),
  category: z.string(),
  sellerId: z.string().uuid(),
  images: z.array(z.string().url()).default([]),
});

// Get all products with pagination, search, and filters
router.get('/', async (req, res) => {
  const page = parseInt(req.query.page as string) || 1;
  const limit = parseInt(req.query.limit as string) || 10;
  const skip = (page - 1) * limit;

  const { search, category, minPrice, maxPrice } = req.query;

  const where: any = {
    seller: { isVerified: true },
    ...(search && {
      OR: [
        { name: { contains: String(search), mode: 'insensitive' } },
        { description: { contains: String(search), mode: 'insensitive' } },
      ],
    }),
    ...(category && { category: String(category) }),
    ...((minPrice || maxPrice) && {
      price: {
        ...(minPrice && { gte: parseFloat(String(minPrice)) }),
        ...(maxPrice && { lte: parseFloat(String(maxPrice)) }),
      },
    }),
  };

  try {
    const [products, total] = await Promise.all([
      prisma.product.findMany({
        where,
        skip,
        take: limit,
        include: { seller: true },
        orderBy: { createdAt: 'desc' }
      }),
      prisma.product.count({ where })
    ]);

    res.json({
      products,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    res.status(500).json({ message: 'Error fetching products' });
  }
});

// Get product by ID
router.get('/:id', async (req, res) => {
  try {
    const product = await prisma.product.findUnique({
      where: { id: req.params.id as string },
      include: { seller: true, reviews: true }
    });
    if (!product) return res.status(404).json({ message: 'Product not found' });
    res.json(product);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching product' });
  }
});

// Create product (Seller only)
router.post('/', authMiddleware, roleGuard(['SELLER', 'ADMIN']), async (req, res) => {
  try {
    const data = productSchema.parse(req.body);
    const product = await prisma.product.create({
      data
    });
    res.status(201).json(product);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ errors: error.issues });
    }
    res.status(500).json({ message: 'Error creating product' });
  }
});

// Update product (Seller or Admin)
router.patch('/:id', authMiddleware, roleGuard(['SELLER', 'ADMIN']), async (req: AuthRequest, res) => {
  try {
    const data = productSchema.partial().parse(req.body);
    const userId = req.user?.id;
    const userRole = req.user?.role;

    const product = await prisma.product.findUnique({
      where: { id: req.params.id as string },
      include: { seller: true }
    });

    if (!product) return res.status(404).json({ message: 'Product not found' });

    // Ownership check for Sellers
    if (userRole === 'SELLER' && product.seller.userId !== userId) {
      return res.status(403).json({ message: 'Forbidden: You do not own this product' });
    }

    const updatedProduct = await prisma.product.update({
      where: { id: req.params.id as string },
      data: data as any
    });
    res.json(updatedProduct);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ errors: error.issues });
    }
    res.status(500).json({ message: 'Error updating product' });
  }
});

// Delete product (Seller or Admin)
router.delete('/:id', authMiddleware, roleGuard(['SELLER', 'ADMIN']), async (req: AuthRequest, res) => {
  try {
    const userId = req.user?.id;
    const userRole = req.user?.role;

    const product = await prisma.product.findUnique({
      where: { id: req.params.id as string },
      include: { seller: true }
    });

    if (!product) return res.status(404).json({ message: 'Product not found' });

    // Ownership check for Sellers
    if (userRole === 'SELLER' && product.seller.userId !== userId) {
      return res.status(403).json({ message: 'Forbidden: You do not own this product' });
    }

    await prisma.product.delete({
      where: { id: req.params.id as string }
    });
    res.json({ message: 'Product deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting product' });
  }
});

export default router;
