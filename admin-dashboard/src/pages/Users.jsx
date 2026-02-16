import { useState, useEffect, Fragment } from 'react';
import { supabase } from '../lib/supabase';
import { Search, ChevronDown, ChevronRight, Star, Zap, Plus, UserPlus } from 'lucide-react';
import { Input } from '@/components/ui/input';
import { Card } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Avatar, AvatarFallback } from '@/components/ui/avatar';
import { Skeleton } from '@/components/ui/skeleton';
import { Separator } from '@/components/ui/separator';
import { Label } from '@/components/ui/label';
import {
  Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription, DialogFooter
} from '@/components/ui/dialog';
import {
  Table, TableHeader, TableBody, TableRow, TableHead, TableCell
} from '@/components/ui/table';

export default function Users() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [expandedUser, setExpandedUser] = useState(null);

  // Add Parent dialog state
  const [showAddParent, setShowAddParent] = useState(false);
  const [newParent, setNewParent] = useState({ parent_first_name: '', parent_last_name: '', email: '', password: '' });
  const [addParentLoading, setAddParentLoading] = useState(false);
  const [addParentError, setAddParentError] = useState('');

  // Add Child dialog state
  const [showAddChild, setShowAddChild] = useState(false);
  const [addChildParentId, setAddChildParentId] = useState(null);
  const [newChild, setNewChild] = useState({ child_name: '', age: '' });
  const [addChildLoading, setAddChildLoading] = useState(false);
  const [addChildError, setAddChildError] = useState('');

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
          children_list: [
            { id: 'c1', child_name: 'Emma Johnson', age: 7, game_progress: [{ total_xp: 1250, current_level: 8, total_stars: 45 }] },
            { id: 'c2', child_name: 'Liam Johnson', age: 5, game_progress: [{ total_xp: 680, current_level: 5, total_stars: 28 }] },
          ],
        },
        {
          id: '2',
          email: 'michael.chen@email.com',
          parent_first_name: 'Michael',
          parent_last_name: 'Chen',
          created_at: '2024-01-20T14:22:00Z',
          children_list: [
            { id: 'c3', child_name: 'Sophia Chen', age: 6, game_progress: [{ total_xp: 2100, current_level: 12, total_stars: 67 }] },
          ],
        },
        {
          id: '3',
          email: 'emma.williams@email.com',
          parent_first_name: 'Emma',
          parent_last_name: 'Williams',
          created_at: '2024-02-01T09:15:00Z',
          children_list: [
            { id: 'c4', child_name: 'Noah Williams', age: 8, game_progress: [{ total_xp: 1890, current_level: 11, total_stars: 58 }] },
            { id: 'c5', child_name: 'Olivia Williams', age: 6, game_progress: [{ total_xp: 950, current_level: 7, total_stars: 38 }] },
            { id: 'c6', child_name: 'Ava Williams', age: 5, game_progress: [{ total_xp: 420, current_level: 4, total_stars: 19 }] },
          ],
        },
        {
          id: '4',
          email: 'david.martinez@email.com',
          parent_first_name: 'David',
          parent_last_name: 'Martinez',
          created_at: '2024-02-03T16:45:00Z',
          children_list: [
            { id: 'c7', child_name: 'Lucas Martinez', age: 7, game_progress: [{ total_xp: 1560, current_level: 9, total_stars: 52 }] },
          ],
        },
        {
          id: '5',
          email: 'lisa.anderson@email.com',
          parent_first_name: 'Lisa',
          parent_last_name: 'Anderson',
          created_at: '2024-02-05T11:20:00Z',
          children_list: [
            { id: 'c8', child_name: 'Mia Anderson', age: 6, game_progress: [{ total_xp: 1120, current_level: 8, total_stars: 41 }] },
            { id: 'c9', child_name: 'Ethan Anderson', age: 8, game_progress: [{ total_xp: 2450, current_level: 14, total_stars: 78 }] },
          ],
        },
      ];

      setUsers(mockUsers);
      setLoading(false);

      // Uncomment below to use real Supabase data
      /*
      const { data, error } = await supabase
        .from('accounts')
        .select('*, children_list:children(*, game_progress(total_xp, current_level, total_stars))')
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

  const toggleExpand = (userId) => {
    setExpandedUser(expandedUser === userId ? null : userId);
  };

  // --- Add Parent ---
  const handleAddParent = async (e) => {
    e.preventDefault();
    setAddParentError('');

    if (!newParent.parent_first_name || !newParent.parent_last_name || !newParent.email || !newParent.password) {
      setAddParentError('All fields are required.');
      return;
    }

    setAddParentLoading(true);
    try {
      // Mock: add to local state
      const mockId = crypto.randomUUID();
      setUsers(prev => [{
        id: mockId,
        email: newParent.email,
        parent_first_name: newParent.parent_first_name,
        parent_last_name: newParent.parent_last_name,
        created_at: new Date().toISOString(),
        children_list: [],
      }, ...prev]);

      // Uncomment below for real Supabase integration
      /*
      // 1. Create auth user
      const { data: authData, error: authError } = await supabase.auth.admin.createUser({
        email: newParent.email,
        password: newParent.password,
        email_confirm: true,
      });
      if (authError) throw authError;

      // 2. Insert account row
      const { error: insertError } = await supabase
        .from('accounts')
        .insert({
          id: authData.user.id,
          email: newParent.email,
          parent_first_name: newParent.parent_first_name,
          parent_last_name: newParent.parent_last_name,
        });
      if (insertError) throw insertError;

      // 3. Refresh list
      await fetchUsers();
      */

      setShowAddParent(false);
      setNewParent({ parent_first_name: '', parent_last_name: '', email: '', password: '' });
    } catch (error) {
      setAddParentError(error.message || 'Failed to add parent.');
    } finally {
      setAddParentLoading(false);
    }
  };

  // --- Add Child ---
  const openAddChild = (parentId, e) => {
    e.stopPropagation();
    setAddChildParentId(parentId);
    setNewChild({ child_name: '', age: '' });
    setAddChildError('');
    setShowAddChild(true);
  };

  const handleAddChild = async (e) => {
    e.preventDefault();
    setAddChildError('');

    if (!newChild.child_name) {
      setAddChildError('Child name is required.');
      return;
    }

    if (newChild.age && (isNaN(newChild.age) || newChild.age < 1 || newChild.age > 18)) {
      setAddChildError('Age must be between 1 and 18.');
      return;
    }

    setAddChildLoading(true);
    try {
      // Mock: add to local state
      const mockChildId = crypto.randomUUID();
      setUsers(prev => prev.map(user => {
        if (user.id !== addChildParentId) return user;
        return {
          ...user,
          children_list: [
            ...user.children_list,
            {
              id: mockChildId,
              child_name: newChild.child_name,
              age: newChild.age ? parseInt(newChild.age) : null,
              game_progress: [{ total_xp: 0, current_level: 1, total_stars: 0 }],
            },
          ],
        };
      }));

      // Uncomment below for real Supabase integration
      /*
      const { error } = await supabase
        .from('children')
        .insert({
          account_id: addChildParentId,
          child_name: newChild.child_name,
          age: newChild.age ? parseInt(newChild.age) : null,
        });
      if (error) throw error;

      await fetchUsers();
      */

      setShowAddChild(false);
      setNewChild({ child_name: '', age: '' });
      setAddChildParentId(null);
    } catch (error) {
      setAddChildError(error.message || 'Failed to add child.');
    } finally {
      setAddChildLoading(false);
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

  const addChildParent = users.find(u => u.id === addChildParentId);

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
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-semibold tracking-tight">Parents</h1>
          <p className="text-sm text-muted-foreground">
            {users.length} registered parent {users.length === 1 ? 'account' : 'accounts'}
          </p>
        </div>
        <Button onClick={() => setShowAddParent(true)}>
          <UserPlus className="h-4 w-4" />
          Add Parent
        </Button>
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
              <TableHead className="w-10"></TableHead>
              <TableHead>Parent</TableHead>
              <TableHead>Email</TableHead>
              <TableHead>Children</TableHead>
              <TableHead>Joined</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {filteredUsers.map((user) => {
              const isExpanded = expandedUser === user.id;
              const childrenList = user.children_list || [];
              return (
                <Fragment key={user.id}>
                  <TableRow
                    className="cursor-pointer"
                    onClick={() => toggleExpand(user.id)}
                  >
                    <TableCell className="w-10 pr-0">
                      {isExpanded
                        ? <ChevronDown className="h-4 w-4 text-muted-foreground" />
                        : <ChevronRight className="h-4 w-4 text-muted-foreground" />
                      }
                    </TableCell>
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
                        {childrenList.length}
                      </Badge>
                    </TableCell>
                    <TableCell className="text-muted-foreground">
                      {new Date(user.created_at).toLocaleDateString('en-US', {
                        month: 'short', day: 'numeric', year: 'numeric'
                      })}
                    </TableCell>
                  </TableRow>

                  {isExpanded && (
                    <TableRow key={`${user.id}-children`}>
                      <TableCell colSpan={5} className="bg-muted/50 p-0">
                        <div className="px-6 py-4">
                          <div className="mb-3 flex items-center justify-between">
                            <p className="text-sm font-medium text-muted-foreground">
                              {user.parent_first_name}'s Children
                            </p>
                            <Button
                              size="sm"
                              variant="outline"
                              onClick={(e) => openAddChild(user.id, e)}
                            >
                              <Plus className="h-3.5 w-3.5" />
                              Add Child
                            </Button>
                          </div>
                          {childrenList.length === 0 ? (
                            <p className="text-sm text-muted-foreground">No children registered yet.</p>
                          ) : (
                            <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
                              {childrenList.map((child) => {
                                const progress = child.game_progress?.[0];
                                return (
                                  <div
                                    key={child.id}
                                    className="flex items-start gap-3 rounded-lg border bg-background p-3"
                                  >
                                    <Avatar className="h-9 w-9">
                                      <AvatarFallback className="text-xs font-medium">
                                        {(child.child_name || '?')[0].toUpperCase()}
                                      </AvatarFallback>
                                    </Avatar>
                                    <div className="min-w-0 flex-1">
                                      <div className="flex items-center justify-between gap-2">
                                        <p className="truncate text-sm font-medium">{child.child_name}</p>
                                        <Badge variant="secondary" className="shrink-0 text-xs">
                                          Lv. {progress?.current_level || 1}
                                        </Badge>
                                      </div>
                                      <p className="text-xs text-muted-foreground">
                                        {child.age ? `Age ${child.age}` : 'Age not set'}
                                      </p>
                                      <Separator className="my-2" />
                                      <div className="flex items-center gap-3">
                                        <div className="flex items-center gap-1 text-xs text-muted-foreground">
                                          <Zap className="h-3 w-3" />
                                          <span>{progress?.total_xp || 0} XP</span>
                                        </div>
                                        <div className="flex items-center gap-1 text-xs text-muted-foreground">
                                          <Star className="h-3 w-3" />
                                          <span>{progress?.total_stars || 0}</span>
                                        </div>
                                      </div>
                                    </div>
                                  </div>
                                );
                              })}
                            </div>
                          )}
                        </div>
                      </TableCell>
                    </TableRow>
                  )}
                </Fragment>
              );
            })}
          </TableBody>
        </Table>

        {filteredUsers.length === 0 && (
          <div className="py-12 text-center text-sm text-muted-foreground">
            No parents found matching your search.
          </div>
        )}
      </Card>

      {/* Add Parent Dialog */}
      <Dialog open={showAddParent} onOpenChange={setShowAddParent}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Add New Parent</DialogTitle>
            <DialogDescription>
              Create a new parent account. They will be able to log in with these credentials.
            </DialogDescription>
          </DialogHeader>
          <form onSubmit={handleAddParent} className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="first_name">First Name</Label>
                <Input
                  id="first_name"
                  placeholder="John"
                  value={newParent.parent_first_name}
                  onChange={(e) => setNewParent(p => ({ ...p, parent_first_name: e.target.value }))}
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="last_name">Last Name</Label>
                <Input
                  id="last_name"
                  placeholder="Doe"
                  value={newParent.parent_last_name}
                  onChange={(e) => setNewParent(p => ({ ...p, parent_last_name: e.target.value }))}
                />
              </div>
            </div>
            <div className="space-y-2">
              <Label htmlFor="email">Email</Label>
              <Input
                id="email"
                type="email"
                placeholder="parent@example.com"
                value={newParent.email}
                onChange={(e) => setNewParent(p => ({ ...p, email: e.target.value }))}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="password">Password</Label>
              <Input
                id="password"
                type="password"
                placeholder="Minimum 6 characters"
                value={newParent.password}
                onChange={(e) => setNewParent(p => ({ ...p, password: e.target.value }))}
              />
            </div>
            {addParentError && (
              <p className="text-sm text-destructive">{addParentError}</p>
            )}
            <DialogFooter>
              <Button type="button" variant="outline" onClick={() => setShowAddParent(false)}>
                Cancel
              </Button>
              <Button type="submit" disabled={addParentLoading}>
                {addParentLoading ? 'Creating...' : 'Create Parent'}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      {/* Add Child Dialog */}
      <Dialog open={showAddChild} onOpenChange={setShowAddChild}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Add Child</DialogTitle>
            <DialogDescription>
              Add a new child profile for {addChildParent?.parent_first_name} {addChildParent?.parent_last_name}.
            </DialogDescription>
          </DialogHeader>
          <form onSubmit={handleAddChild} className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="child_name">Child Name</Label>
              <Input
                id="child_name"
                placeholder="Child's display name"
                value={newChild.child_name}
                onChange={(e) => setNewChild(c => ({ ...c, child_name: e.target.value }))}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="child_age">Age (optional)</Label>
              <Input
                id="child_age"
                type="number"
                min="1"
                max="18"
                placeholder="e.g. 6"
                value={newChild.age}
                onChange={(e) => setNewChild(c => ({ ...c, age: e.target.value }))}
              />
            </div>
            {addChildError && (
              <p className="text-sm text-destructive">{addChildError}</p>
            )}
            <DialogFooter>
              <Button type="button" variant="outline" onClick={() => setShowAddChild(false)}>
                Cancel
              </Button>
              <Button type="submit" disabled={addChildLoading}>
                {addChildLoading ? 'Adding...' : 'Add Child'}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>
    </div>
  );
}
