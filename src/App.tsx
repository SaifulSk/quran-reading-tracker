import { useEffect, useState } from 'react';
import { BookOpen, LogOut } from 'lucide-react';
import { supabase, Reader, Chapter, Assignment } from './lib/supabase';
import { useAuth } from './hooks/useAuth';
import { Login } from './components/Login';
import { ReaderManagement } from './components/ReaderManagement';
import { ChapterGrid } from './components/ChapterGrid';
import { ProgressSummary } from './components/ProgressSummary';

function App() {
  const { user, loading: authLoading, error: authError, signUp, signIn, signOut, setError: setAuthError } = useAuth();
  const [organizationId, setOrganizationId] = useState<string | null>(null);
  const [readers, setReaders] = useState<Reader[]>([]);
  const [chapters, setChapters] = useState<Chapter[]>([]);
  const [assignments, setAssignments] = useState<Assignment[]>([]);
  const [loading, setLoading] = useState(true);
  const [authSubmitting, setAuthSubmitting] = useState(false);

  const fetchOrganization = async (userId: string) => {
    try {
      const { data, error } = await supabase
        .from('organization_members')
        .select('organization_id')
        .eq('user_id', userId)
        .maybeSingle();

      if (error) {
        console.error('Error fetching organization:', error);
        return null;
      }

      return data?.organization_id || null;
    } catch (error) {
      console.error('Error fetching organization:', error);
      return null;
    }
  };

  const fetchData = async (orgId: string) => {
    try {
      const [readersResult, chaptersResult, assignmentsResult] = await Promise.all([
        supabase.from('readers').select('*').eq('organization_id', orgId).order('name'),
        supabase.from('chapters').select('*').order('id'),
        supabase.from('assignments').select('*').eq('organization_id', orgId).order('chapter_id')
      ]);

      if (readersResult.data) setReaders(readersResult.data);
      if (chaptersResult.data) setChapters(chaptersResult.data);
      if (assignmentsResult.data) setAssignments(assignmentsResult.data);
    } catch (error) {
      console.error('Error fetching data:', error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (user) {
      (async () => {
        const orgId = await fetchOrganization(user.id);
        setOrganizationId(orgId);
        if (orgId) {
          await fetchData(orgId);
        } else {
          setLoading(false);
        }
      })();
    } else if (!authLoading) {
      setLoading(false);
    }
  }, [user, authLoading]);

  const handleSignUp = async (email: string, password: string, name: string) => {
    setAuthSubmitting(true);
    const result = await signUp(email, password, name);
    setAuthSubmitting(false);
    if (result) {
      setAuthError(null);
    }
  };

  const handleSignIn = async (email: string, password: string) => {
    setAuthSubmitting(true);
    const result = await signIn(email, password);
    setAuthSubmitting(false);
    if (result) {
      setAuthError(null);
    }
  };

  const handleSignOut = async () => {
    await signOut();
  };

  if (!user) {
    return (
      <Login
        onSignUp={handleSignUp}
        onSignIn={handleSignIn}
        error={authError}
        loading={authSubmitting}
      />
    );
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-emerald-50 to-teal-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-emerald-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Loading...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-emerald-50 to-teal-50">
      <div className="container mx-auto px-4 py-8">
        <header className="mb-8 flex items-start justify-between">
          <div>
            <div className="flex items-center gap-3 mb-2">
              <BookOpen size={32} className="text-emerald-600" />
              <h1 className="text-3xl font-bold text-gray-800">Qur'an Reading Tracker</h1>
            </div>
            <p className="text-gray-600">
              Manage chapter distribution and track reading progress across 30 Juz
            </p>
          </div>
          <div className="flex flex-col items-end gap-2">
            <p className="text-sm text-gray-600">{user.email}</p>
            <button
              onClick={handleSignOut}
              className="flex items-center gap-2 px-4 py-2 text-sm bg-red-50 hover:bg-red-100 text-red-600 rounded-lg transition"
            >
              <LogOut size={16} />
              Sign Out
            </button>
          </div>
        </header>

        <div className="grid lg:grid-cols-3 gap-6 mb-6">
          <div className="lg:col-span-1">
            <ReaderManagement
              readers={readers}
              organizationId={organizationId}
              onReaderAdded={() => organizationId && fetchData(organizationId)}
              onReaderRemoved={() => organizationId && fetchData(organizationId)}
            />
          </div>
          <div className="lg:col-span-2">
            <ProgressSummary assignments={assignments} readers={readers} />
          </div>
        </div>

        <ChapterGrid
          chapters={chapters}
          assignments={assignments}
          readers={readers}
          organizationId={organizationId}
          onAssignmentChange={() => organizationId && fetchData(organizationId)}
        />
      </div>
    </div>
  );
}

export default App;
