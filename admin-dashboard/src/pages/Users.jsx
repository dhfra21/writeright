import { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import { Search } from 'lucide-react';
import { Input } from '@/components/ui/input';
import { Card } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Avatar, AvatarFallback } from '@/components/ui/avatar';
import { Skeleton } from '@/components/ui/skeleton';
import {
  Table, TableHeader, TableBody, TableRow, TableHead, TableCell
} from '@/components/ui/table';

export default function Users() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    try {
      // Mock data for demonstration
      const mockUsers = [
        {
          id: '1',
          email: 'sarah.johnson@email.com',
          parent_first_name: 'Sarah',
          parent_last_name: 'Johnson',
          created_at: '2024-01-15T10:30:00Z',
          children: [{ count: 2 }],
        },
        {
          id: '2',
          email: 'michael.chen@email.com',
          parent_first_name: 'Michael',
          parent_last_name: 'Chen',
          created_at: '2024-01-20T14:22:00Z',
          children: [{ count: 1 }],
        },
        {
          id: '3',
          email: 'emma.williams@email.com',
          parent_first_name: 'Emma',
          parent_last_name: 'Williams',
          created_at: '2024-02-01T09:15:00Z',
          children: [{ count: 3 }],
        },
        {
          id: '4',
          email: 'david.martinez@email.com',
          parent_first_name: 'David',
          parent_last_name: 'Martinez',
          created_at: '2024-02-03T16:45:00Z',
          children: [{ count: 1 }],
        },
        {
          id: '5',
          email: 'lisa.anderson@email.com',
          parent_first_name: 'Lisa',
          parent_last_name: 'Anderson',
          created_at: '2024-02-05T11:20:00Z',
          children: [{ count: 2 }],
        },
      ];

      setUsers(mockUsers);
      setLoading(false);

      // Uncomment below to use real Supabase data
      /*
      const { data, error } = await supabase
        .from('accounts')
        .select('*, children(count)')
        .order('created_at', { ascending: false });

      if (error) throw error;
      setUsers(data || []);
      setLoading(false);
      */
    } catch (error) {
      console.error('Error fetching users:', error);
      setLoading(false);
    }
  };

  const filteredUsers = users.filter(user =>
    user.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
    user.parent_first_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    user.parent_last_name.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const getInitials = (first, last) => {
    return `${(first || '')[0] || ''}${(last || '')[0] || ''}`.toUpperCase();
  };

  if (loading) {
    return (
      <div className="space-y-6">
        <div>
          <Skeleton className="h-8 w-48" />
          <Skeleton className="mt-2 h-4 w-64" />
        </div>
        <Skeleton className="h-9 w-full max-w-sm" />
        <Skeleton className="h-96 rounded-lg" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-semibold tracking-tight">Parents</h1>
        <p className="text-sm text-muted-foreground">
          {users.length} registered parent {users.length === 1 ? 'account' : 'accounts'}
        </p>
      </div>

      <div className="relative max-w-sm">
        <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
        <Input
          placeholder="Search by name or email..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="pl-9"
        />
      </div>

      <Card>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Parent</TableHead>
              <TableHead>Email</TableHead>
              <TableHead>Children</TableHead>
              <TableHead>Joined</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {filteredUsers.map((user) => (
              <TableRow key={user.id}>
                <TableCell>
                  <div className="flex items-center gap-3">
                    <Avatar className="h-8 w-8">
                      <AvatarFallback className="text-xs">
                        {getInitials(user.parent_first_name, user.parent_last_name)}
                      </AvatarFallback>
                    </Avatar>
                    <span className="font-medium">
                      {user.parent_first_name} {user.parent_last_name}
                    </span>
                  </div>
                </TableCell>
                <TableCell className="text-muted-foreground">
                  {user.email}
                </TableCell>
                <TableCell>
                  <Badge variant="secondary">
                    {user.children?.[0]?.count || 0}
                  </Badge>
                </TableCell>
                <TableCell className="text-muted-foreground">
                  {new Date(user.created_at).toLocaleDateString('en-US', {
                    month: 'short', day: 'numeric', year: 'numeric'
                  })}
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>

        {filteredUsers.length === 0 && (
          <div className="py-12 text-center text-sm text-muted-foreground">
            No parents found matching your search.
          </div>
        )}
      </Card>
    </div>
  );
}
