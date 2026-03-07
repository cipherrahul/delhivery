import { Router } from 'express';
import { PrismaClient } from '@prisma/client';
import { authMiddleware, roleGuard } from '../../shared/middlewares/auth.middleware.js';
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
  images: z.array(z.string().url()).optional(),
});

// Get all products with pagination
router.get('/', async (req, res) => {
  const page = parseInt(req.query.page as string) || 1;
  const limit = parseInt(req.query.limit as string) || 10;
  const skip = (page - 1) * limit;

  try {
    const [products, total] = await Promise.all([
      prisma.product.findMany({
        skip,
        take: limit,
        include: { seller: true },
        orderBy: { createdAt: 'desc' }
      }),
      prisma.product.count()
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
      where: { id: req.params.id },
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

export default router;
