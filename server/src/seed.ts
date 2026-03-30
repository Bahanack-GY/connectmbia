/**
 * Seed script — creates one admin account if none exists.
 *
 * Run:  npx ts-node -r tsconfig-paths/register src/seed.ts
 */
import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';

const MONGO_URI =
  process.env.MONGODB_URI ?? 'mongodb://localhost:27017/mbiaconsulting';

const ADMIN_EMAIL = process.env.SEED_EMAIL ?? 'admin@mbia.com';
const ADMIN_PASSWORD = process.env.SEED_PASSWORD ?? 'Admin@2024!';
const ADMIN_NAME = process.env.SEED_NAME ?? 'Administrateur';

const UserSchema = new mongoose.Schema(
  {
    name: String,
    email: { type: String, lowercase: true, trim: true },
    phone: String,
    password: String,
    role: { type: String, default: 'user' },
    avatar: String,
  },
  { timestamps: true },
);

async function seed() {
  await mongoose.connect(MONGO_URI);
  console.log('Connected to MongoDB');

  const User = mongoose.model('User', UserSchema);

  const existing = await User.findOne({ email: ADMIN_EMAIL.toLowerCase() });

  if (existing) {
    if (existing.role !== 'admin') {
      await User.findByIdAndUpdate(existing._id, { role: 'admin' });
      console.log(`User ${ADMIN_EMAIL} already existed — role upgraded to admin.`);
    } else {
      console.log(`Admin ${ADMIN_EMAIL} already exists. Nothing to do.`);
    }
    await mongoose.disconnect();
    return;
  }

  const hash = await bcrypt.hash(ADMIN_PASSWORD, 12);
  await User.create({
    name: ADMIN_NAME,
    email: ADMIN_EMAIL.toLowerCase(),
    password: hash,
    role: 'admin',
  });

  console.log('');
  console.log('Admin account created successfully');
  console.log(`  Email    : ${ADMIN_EMAIL}`);
  console.log(`  Password : ${ADMIN_PASSWORD}`);
  console.log('');
  console.log('Change the password after first login.');

  await mongoose.disconnect();
}

seed().catch((err) => {
  console.error('Seed failed:', err);
  process.exit(1);
});
