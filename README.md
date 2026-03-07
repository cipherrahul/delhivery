# Delhivery - Logistics & E-commerce Platform

A comprehensive logistics and e-commerce platform featuring a robust Node.js backend and a cross-platform Flutter mobile application.

## 🚀 Project Status: In Development

- **Backend**: Fully functional with core modules implemented (Auth, Products, Cart, Orders, Payments, Tracking).
- **Frontend**: Flutter mobile application in active development, focusing on premium UI/UX for Customers, Sellers, and Admins.

## 🛠 Tech Stack

### Backend
- **Core**: Node.js, Express.js (v5+)
- **Database**: PostgreSQL with Prisma ORM
- **Cache & Real-time**: Redis, Socket.io
- **Security**: JWT Authentication, bcryptjs, Helmet, Express Rate Limit
- **Validation**: Zod
- **Testing**: TypeScript (`tsc` verification)

### Frontend
- **Framework**: Flutter
- **Architecture**: Feature-based, clean architecture logic
- **State Management**: (In progress)

## 🏗 Project Architecture

The project is organized as a monorepo (though currently managed as separate directories for backend and frontend):

- `backend/`: Node.js Express application.
  - `src/modules/`: Domain-driven modules (Auth, Orders, etc.).
  - `prisma/`: Database schema and migrations.
- `frontend/`: Flutter mobile application.
  - `lib/features/`: Feature-based organization (Customer, Seller, Admin).

## ✨ Key Features

### 👤 Customer
- Secure Authentication (Signup/Login).
- Product browsing and searching.
- Shopping cart management (with persistent storage).
- Order placement and payment integration.
- Real-time shipment tracking.

### 🏢 Seller
- Store management.
- Product catalog management (Add/Update/Delete products).
- Order fulfillment and tracking updates.

### 🛡 Admin
- User and Seller management.
- Platform-wide monitoring.
- Logistics overview and tracking.

## 🚦 Getting Started

### Backend Setup
1. Navigate to the `backend/` directory.
2. Install dependencies: `npm install`.
3. Set up your `.env` file with `DATABASE_URL`.
4. Run Prisma migrations: `npx prisma migrate dev`.
5. Generate Prisma Client: `npx prisma generate`.
6. Start the server: (Check `package.json` for start scripts).

### Frontend Setup
1. Navigate to the `frontend/` directory.
2. Install Flutter dependencies: `flutter pub get`.
3. Run the application: `flutter run`.

---
*Built with focus on scalability, security, and premium user experience.*
