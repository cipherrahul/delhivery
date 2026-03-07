import type { Express } from 'express';
import authRoutes from './modules/auth/auth.controller.js';
import productRoutes from './modules/products/products.controller.js';
import trackingRoutes from './modules/tracking/tracking.controller.js';
import userRoutes from './modules/users/users.controller.js';
import sellerRoutes from './modules/seller/seller.controller.js';
import orderRoutes from './modules/orders/orders.controller.js';
import paymentRoutes from './modules/payments/payments.controller.js';
import reviewRoutes from './modules/reviews/reviews.controller.js';
import cartRoutes from './modules/cart/cart.controller.js';
import adminRoutes from './modules/admin/admin.controller.js';

export const mountModules = (app: Express) => {
  // Mount Modules
  app.use('/api/auth', authRoutes);
  app.use('/api/admin', adminRoutes);
  app.use('/api/products', productRoutes);
  app.use('/api/tracking', trackingRoutes);
  app.use('/api/users', userRoutes);
  app.use('/api/seller', sellerRoutes);
  app.use('/api/orders', orderRoutes);
  app.use('/api/payments', paymentRoutes);
  app.use('/api/reviews', reviewRoutes);
  app.use('/api/cart', cartRoutes);
  
  // Error handling middleware
  app.use((err: any, req: any, res: any, next: any) => {
    console.error(err.stack);
    res.status(500).json({ message: 'Something went wrong!' });
  });
};
