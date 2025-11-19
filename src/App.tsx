import { useEffect, useState } from 'react';
import { BookOpen } from 'lucide-react';
import { supabase, Reader, Chapter, Assignment } from './lib/supabase';
import { ReaderManagement } from './components/ReaderManagement';
import { ChapterGrid } from './components/ChapterGrid';
import { ProgressSummary } from './components/ProgressSummary';

function App() {
  const [readers, setReaders] = useState<Reader[]>([]);
  const [chapters, setChapters] = useState<Chapter[]>([]);
  const [assignments, setAssignments] = useState<Assignment[]>([]);
  const [loading, setLoading] = useState(true);

  const fetchData = async () => {
    try {
      const [readersResult, chaptersResult, assignmentsResult] = await Promise.all([
        supabase.from('readers').select('*').order('name'),
        supabase.from('chapters').select('*').order('id'),
        supabase.from('assignments').select('*').order('chapter_id')
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
    fetchData();
  }, []);

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
        <header className="mb-8">
          <div className="flex items-center gap-3 mb-2">
            <BookOpen size={32} className="text-emerald-600" />
            <h1 className="text-3xl font-bold text-gray-800">Qur'an Reading Tracker</h1>
          </div>
          <p className="text-gray-600">
            Manage chapter distribution and track reading progress across 30 Juz
          </p>
        </header>

        <div className="grid lg:grid-cols-3 gap-6 mb-6">
          <div className="lg:col-span-1">
            <ReaderManagement
              readers={readers}
              onReaderAdded={fetchData}
              onReaderRemoved={fetchData}
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
          onAssignmentChange={fetchData}
        />
      </div>
    </div>
  );
}

export default App;
