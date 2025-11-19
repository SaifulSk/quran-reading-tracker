import { useState } from 'react';
import { Chapter, Reader, Assignment, supabase } from '../lib/supabase';
import { Check, Clock, Circle } from 'lucide-react';

type ChapterGridProps = {
  chapters: Chapter[];
  assignments: Assignment[];
  readers: Reader[];
  onAssignmentChange: () => void;
};

export function ChapterGrid({ chapters, assignments, readers, onAssignmentChange }: ChapterGridProps) {
  const [openDropdown, setOpenDropdown] = useState<number | null>(null);

  const getAssignmentForChapter = (chapterId: number) => {
    return assignments.find(a => a.chapter_id === chapterId);
  };

  const getReaderName = (readerId: string) => {
    return readers.find(r => r.id === readerId)?.name || 'Unknown';
  };

  const getReaderColor = (readerId: string) => {
    return readers.find(r => r.id === readerId)?.color || '#3B82F6';
  };

  const handleAssignChapter = async (chapterId: number, readerId: string) => {
    try {
      const { error } = await supabase
        .from('assignments')
        .insert([{
          chapter_id: chapterId,
          reader_id: readerId,
          status: 'pending'
        }]);

      if (error) throw error;
      setOpenDropdown(null);
      onAssignmentChange();
    } catch (error) {
      console.error('Error assigning chapter:', error);
      alert('Failed to assign chapter. It may already be assigned.');
    }
  };

  const handleUpdateStatus = async (assignmentId: string, currentStatus: string) => {
    const statusOrder = ['pending', 'in_progress', 'completed'];
    const currentIndex = statusOrder.indexOf(currentStatus);
    const nextStatus = statusOrder[(currentIndex + 1) % statusOrder.length];

    const updates: { status: string; completed_at?: string | null } = { status: nextStatus };
    if (nextStatus === 'completed') {
      updates.completed_at = new Date().toISOString();
    } else {
      updates.completed_at = null;
    }

    try {
      const { error } = await supabase
        .from('assignments')
        .update(updates)
        .eq('id', assignmentId);

      if (error) throw error;
      onAssignmentChange();
    } catch (error) {
      console.error('Error updating status:', error);
    }
  };

  const handleUnassign = async (assignmentId: string) => {
    if (!confirm('Unassign this chapter?')) return;

    try {
      const { error } = await supabase
        .from('assignments')
        .delete()
        .eq('id', assignmentId);

      if (error) throw error;
      onAssignmentChange();
    } catch (error) {
      console.error('Error unassigning:', error);
    }
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'completed':
        return <Check size={16} className="text-emerald-600" />;
      case 'in_progress':
        return <Clock size={16} className="text-amber-600" />;
      default:
        return <Circle size={16} className="text-gray-400" />;
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'completed':
        return 'bg-emerald-50 border-emerald-200';
      case 'in_progress':
        return 'bg-amber-50 border-amber-200';
      default:
        return 'bg-gray-50 border-gray-200';
    }
  };

  return (
    <div className="bg-white rounded-lg shadow-md p-6 mb-6">
      <h2 className="text-xl font-semibold text-gray-800 mb-4">Qur'an Chapters (Juz)</h2>

      <div className="mb-4 flex gap-4 text-sm">
        <div className="flex items-center gap-2">
          <Circle size={16} className="text-gray-400" />
          <span>Pending</span>
        </div>
        <div className="flex items-center gap-2">
          <Clock size={16} className="text-amber-600" />
          <span>In Progress</span>
        </div>
        <div className="flex items-center gap-2">
          <Check size={16} className="text-emerald-600" />
          <span>Completed</span>
        </div>
      </div>

      <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-5 lg:grid-cols-6 gap-3">
        {chapters.map((chapter) => {
          const assignment = getAssignmentForChapter(chapter.id);
          const isDropdownOpen = openDropdown === chapter.id;

          return (
            <div key={chapter.id} className="relative">
              <div
                className={`border-2 rounded-lg p-4 cursor-pointer transition-all hover:shadow-md ${
                  assignment
                    ? `border-2`
                    : 'bg-white border-gray-200 hover:border-emerald-300'
                }`}
                style={assignment ? {
                  backgroundColor: `${getReaderColor(assignment.reader_id)}20`,
                  borderColor: getReaderColor(assignment.reader_id),
                } : undefined}
                onClick={() => {
                  if (!assignment) {
                    setOpenDropdown(isDropdownOpen ? null : chapter.id);
                  }
                }}
              >
                <div className="flex items-center justify-between mb-2">
                  <span className="text-2xl font-bold text-gray-700">{chapter.id}</span>
                  {assignment && getStatusIcon(assignment.status)}
                </div>

                {assignment ? (
                  <div className="space-y-2">
                    <p className="text-xs font-medium text-gray-600 truncate">
                      {getReaderName(assignment.reader_id)}
                    </p>
                    <div className="flex gap-1">
                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          handleUpdateStatus(assignment.id, assignment.status);
                        }}
                        className="flex-1 text-xs px-2 py-1 bg-white border border-gray-300 rounded hover:bg-gray-50"
                      >
                        Next
                      </button>
                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          handleUnassign(assignment.id);
                        }}
                        className="text-xs px-2 py-1 bg-white border border-red-300 text-red-600 rounded hover:bg-red-50"
                      >
                        ✕
                      </button>
                    </div>
                  </div>
                ) : (
                  <p className="text-xs text-gray-400">Click to assign</p>
                )}
              </div>

              {isDropdownOpen && !assignment && readers.length > 0 && (
                <div
                  className="absolute top-full left-0 right-0 mt-2 bg-white border-2 border-emerald-300 rounded-lg shadow-lg z-10"
                  onClick={(e) => e.stopPropagation()}
                >
                  {readers.map((reader) => (
                    <button
                      key={reader.id}
                      onClick={() => handleAssignChapter(chapter.id, reader.id)}
                      className="w-full text-left px-3 py-2 text-sm hover:bg-emerald-50 first:rounded-t-md last:rounded-b-md border-b last:border-b-0 border-gray-100"
                    >
                      {reader.name}
                    </button>
                  ))}
                </div>
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
}
