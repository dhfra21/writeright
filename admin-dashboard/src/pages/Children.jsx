import { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import { Search, Star, Zap } from 'lucide-react';
import { Input } from '@/components/ui/input';
import { Card, CardContent } from '@/components/ui/card';
import { Avatar, AvatarFallback } from '@/components/ui/avatar';
import { Badge } from '@/components/ui/badge';
import { Skeleton } from '@/components/ui/skeleton';
import { Separator } from '@/components/ui/separator';

export default function Children() {
  const [children, setChildren] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');

  useEffect(() => {
    fetchChildren();
  }, []);

  const fetchChildren = async () => {
    try {
      // Mock data for demonstration
      const mockChildren = [
        {
          id: '1',
          child_name: 'Emma Johnson',
          age: 7,
          created_at: '2024-01-15T10:30:00Z',
          accounts: { parent_first_name: 'Sarah', parent_last_name: 'Johnson', email: 'sarah.johnson@email.com' },
          game_progress: [{ total_xp: 1250, current_level: 8, total_stars: 45 }],
        },
        {
          id: '2',
          child_name: 'Liam Johnson',
          age: 5,
          created_at: '2024-01-15T10:30:00Z',
          accounts: { parent_first_name: 'Sarah', parent_last_name: 'Johnson', email: 'sarah.johnson@email.com' },
          game_progress: [{ total_xp: 680, current_level: 5, total_stars: 28 }],
        },
        {
          id: '3',
          child_name: 'Sophia Chen',
          age: 6,
          created_at: '2024-01-20T14:22:00Z',
          accounts: { parent_first_name: 'Michael', parent_last_name: 'Chen', email: 'michael.chen@email.com' },
          game_progress: [{ total_xp: 2100, current_level: 12, total_stars: 67 }],
        },
        {
          id: '4',
          child_name: 'Noah Williams',
          age: 8,
          created_at: '2024-02-01T09:15:00Z',
          accounts: { parent_first_name: 'Emma', parent_last_name: 'Williams', email: 'emma.williams@email.com' },
          game_progress: [{ total_xp: 1890, current_level: 11, total_stars: 58 }],
        },
        {
          id: '5',
          child_name: 'Olivia Williams',
          age: 6,
          created_at: '2024-02-01T09:15:00Z',
          accounts: { parent_first_name: 'Emma', parent_last_name: 'Williams', email: 'emma.williams@email.com' },
          game_progress: [{ total_xp: 950, current_level: 7, total_stars: 38 }],
        },
        {
          id: '6',
          child_name: 'Ava Williams',
          age: 5,
          created_at: '2024-02-01T09:15:00Z',
          accounts: { parent_first_name: 'Emma', parent_last_name: 'Williams', email: 'emma.williams@email.com' },
          game_progress: [{ total_xp: 420, current_level: 4, total_stars: 19 }],
        },
        {
          id: '7',
          child_name: 'Lucas Martinez',
          age: 7,
          created_at: '2024-02-03T16:45:00Z',
          accounts: { parent_first_name: 'David', parent_last_name: 'Martinez', email: 'david.martinez@email.com' },
          game_progress: [{ total_xp: 1560, current_level: 9, total_stars: 52 }],
        },
        {
          id: '8',
          child_name: 'Mia Anderson',
          age: 6,
          created_at: '2024-02-05T11:20:00Z',
          accounts: { parent_first_name: 'Lisa', parent_last_name: 'Anderson', email: 'lisa.anderson@email.com' },
          game_progress: [{ total_xp: 1120, current_level: 8, total_stars: 41 }],
        },
        {
          id: '9',
          child_name: 'Ethan Anderson',
          age: 8,
          created_at: '2024-02-05T11:20:00Z',
          accounts: { parent_first_name: 'Lisa', parent_last_name: 'Anderson', email: 'lisa.anderson@email.com' },
          game_progress: [{ total_xp: 2450, current_level: 14, total_stars: 78 }],
        },
      ];

      setChildren(mockChildren);
      setLoading(false);

      // Uncomment below to use real Supabase data
      /*
      const { data, error } = await supabase
        .from('children')
        .select(`
          *,
          accounts(parent_first_name, parent_last_name, email),
          game_progress(total_xp, current_level, total_stars)
        `)
        .order('created_at', { ascending: false });

      if (error) throw error;
      setChildren(data || []);
      setLoading(false);
      */
    } catch (error) {
      console.error('Error fetching children:', error);
      setLoading(false);
    }
  };

  const filteredChildren = children.filter(child =>
    child.child_name.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const getInitial = (name) => (name || '?')[0].toUpperCase();

  if (loading) {
    return (
      <div className="space-y-6">
        <div>
          <Skeleton className="h-8 w-48" />
          <Skeleton className="mt-2 h-4 w-64" />
        </div>
        <Skeleton className="h-9 w-full max-w-sm" />
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {[...Array(6)].map((_, i) => (
            <Skeleton key={i} className="h-48 rounded-lg" />
          ))}
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-semibold tracking-tight">Children</h1>
        <p className="text-sm text-muted-foreground">
          {children.length} child {children.length === 1 ? 'profile' : 'profiles'}
        </p>
      </div>

      <div className="relative max-w-sm">
        <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
        <Input
          placeholder="Search by name..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="pl-9"
        />
      </div>

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {filteredChildren.map((child) => (
          <Card key={child.id}>
            <CardContent className="p-5">
              <div className="flex items-start gap-3">
                <Avatar className="h-10 w-10">
                  <AvatarFallback className="text-sm font-medium">
                    {getInitial(child.child_name)}
                  </AvatarFallback>
                </Avatar>
                <div className="min-w-0 flex-1">
                  <p className="truncate font-medium">{child.child_name}</p>
                  <p className="text-sm text-muted-foreground">
                    {child.age ? `Age ${child.age}` : 'Age not set'}
                  </p>
                </div>
                <Badge variant="secondary" className="shrink-0">
                  Lv. {child.game_progress?.[0]?.current_level || 1}
                </Badge>
              </div>

              <p className="mt-3 text-xs text-muted-foreground">
                Parent: {child.accounts?.parent_first_name} {child.accounts?.parent_last_name}
              </p>

              <Separator className="my-3" />

              <div className="flex items-center gap-4">
                <div className="flex items-center gap-1.5 text-sm text-muted-foreground">
                  <Zap className="h-3.5 w-3.5" />
                  <span>{child.game_progress?.[0]?.total_xp || 0} XP</span>
                </div>
                <div className="flex items-center gap-1.5 text-sm text-muted-foreground">
                  <Star className="h-3.5 w-3.5" />
                  <span>{child.game_progress?.[0]?.total_stars || 0}</span>
                </div>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>

      {filteredChildren.length === 0 && (
        <div className="py-12 text-center text-sm text-muted-foreground">
          No children found matching your search.
        </div>
      )}
    </div>
  );
}
