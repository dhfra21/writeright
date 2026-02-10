# Admin Dashboard - Handwriting Learning App

A modern React admin dashboard for managing the Children's Handwriting Learning App.

## Features

- ✅ **Authentication** - Secure login with Supabase Auth
- ✅ **Dashboard Overview** - Key metrics and statistics
- ✅ **User Management** - View and search parent accounts
- ✅ **Children Profiles** - Manage child accounts and progress
- ✅ **Analytics** - Detailed insights and performance metrics
- ✅ **Data Visualization** - Charts and graphs using Recharts
- ✅ **Responsive Design** - Modern, beautiful UI

## Tech Stack

- **React** - UI library
- **Vite** - Build tool
- **React Router** - Routing
- **Supabase** - Backend and authentication
- **Recharts** - Data visualization
- **Lucide React** - Icons

## Setup

### 1. Install Dependencies

```bash
cd admin-dashboard
npm install
```

### 2. Configure Environment

Copy `.env.example` to `.env` and add your Supabase credentials:

```bash
cp .env.example .env
```

Edit `.env`:
```env
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key-here
```

### 3. Run Development Server

```bash
npm run dev
```

The dashboard will be available at `http://localhost:5173`

## Project Structure

```
admin-dashboard/
├── src/
│   ├── components/
│   │   ├── Sidebar.jsx         # Navigation sidebar
│   │   └── StatCard.jsx        # Reusable stat card
│   ├── contexts/
│   │   └── AuthContext.jsx     # Authentication context
│   ├── lib/
│   │   └── supabase.js         # Supabase client
│   ├── pages/
│   │   ├── Login.jsx           # Login page
│   │   ├── Dashboard.jsx       # Main dashboard
│   │   ├── Users.jsx           # User management
│   │   ├── Children.jsx        # Children profiles
│   │   └── Analytics.jsx       # Analytics & insights
│   ├── App.jsx                 # Main app component
│   └── main.jsx                # Entry point
├── .env.example                # Environment template
└── package.json
```

## Pages

### Dashboard
- Overview statistics (users, children, sessions, avg score)
- Practice sessions chart (last 7 days)
- Mastery level distribution chart

### Users
- List of all parent accounts
- Search functionality
- View children count per user

### Children
- Grid view of all child profiles
- Display progress (level, XP, stars)
- Parent information

### Analytics
- Practice distribution (letters vs numbers)
- Top performers leaderboard
- Average score by character

## Authentication

The dashboard uses Supabase Auth for authentication. Users must sign in with their email and password to access the admin panel.

**Default login flow:**
1. Navigate to `/login`
2. Enter email and password
3. Click "Sign In"
4. Redirected to dashboard on success

## Data Fetching

All data is fetched directly from Supabase using the Supabase client:

```javascript
import { supabase } from '../lib/supabase';

// Example: Fetch children
const { data, error } = await supabase
  .from('children')
  .select('*')
  .order('created_at', { ascending: false });
```

## Styling

The dashboard uses custom CSS with:
- Modern gradient backgrounds
- Smooth animations and transitions
- Responsive grid layouts
- Card-based design
- Hover effects

## Building for Production

```bash
npm run build
```

The production build will be in the `dist/` directory.

## Deployment

### Recommended Platforms

- **Vercel** - Zero-config deployment
- **Netlify** - Automatic builds
- **GitHub Pages** - Free hosting

### Environment Variables

Make sure to set `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` in your deployment platform.

## Security

- ✅ Protected routes (requires authentication)
- ✅ Supabase RLS policies enforced
- ✅ Environment variables for sensitive data
- ✅ No API keys in client code

## Future Enhancements

- [ ] Export data to CSV/PDF
- [ ] Real-time updates with Supabase subscriptions
- [ ] Advanced filtering and sorting
- [ ] Bulk operations
- [ ] Email notifications
- [ ] Dark mode toggle

## Troubleshooting

### "Missing Supabase environment variables"
Make sure `.env` file exists and contains valid Supabase credentials.

### Charts not displaying
Ensure Recharts is installed: `npm install recharts`

### Authentication not working
Verify Supabase URL and anon key are correct in `.env` file.

## Support

For issues or questions, refer to:
- [React Documentation](https://react.dev/)
- [Vite Documentation](https://vitejs.dev/)
- [Supabase Documentation](https://supabase.com/docs)
- [Recharts Documentation](https://recharts.org/)
