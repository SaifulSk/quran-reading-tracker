import { Assignment, Reader } from '../lib/supabase';
import { BookOpen, CheckCircle2, Clock, User } from 'lucide-react';

type ProgressSummaryProps = {
  assignments: Assignment[];
  readers: Reader[];
};

export function ProgressSummary({ assignments, readers }: ProgressSummaryProps) {
  const totalChapters = 30;
  const assignedCount = assignments.length;
  const pendingCount = assignments.filter(a => a.status === 'pending').length;
  const inProgressCount = assignments.filter(a => a.status === 'in_progress').length;
  const completedCount = assignments.filter(a => a.status === 'completed').length;
  const unassignedCount = totalChapters - assignedCount;

  const completionPercentage = Math.round((completedCount / totalChapters) * 100);

  const getReaderStats = () => {
    return readers.map(reader => {
      const readerAssignments = assignments.filter(a => a.reader_id === reader.id);
      const completed = readerAssignments.filter(a => a.status === 'completed').length;
      const total = readerAssignments.length;
      return { name: reader.name, completed, total };
    }).filter(stat => stat.total > 0);
  };

  return (
    <div className="bg-white rounded-lg shadow-md p-6">
      <h2 className="text-xl font-semibold text-gray-800 mb-4">Progress Summary</h2>

      <div className="mb-6">
        <div className="flex justify-between items-center mb-2">
          <span className="text-sm font-medium text-gray-600">Overall Completion</span>
          <span className="text-2xl font-bold text-emerald-600">{completionPercentage}%</span>
        </div>
        <div className="w-full bg-gray-200 rounded-full h-3">
          <div
            className="bg-emerald-600 h-3 rounded-full transition-all duration-500"
            style={{ width: `${completionPercentage}%` }}
          />
        </div>
      </div>

      <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
        <div className="bg-gray-50 rounded-lg p-4">
          <div className="flex items-center gap-2 mb-1">
            <BookOpen size={18} className="text-gray-500" />
            <span className="text-sm text-gray-600">Unassigned</span>
          </div>
          <p className="text-2xl font-bold text-gray-700">{unassignedCount}</p>
        </div>

        <div className="bg-blue-50 rounded-lg p-4">
          <div className="flex items-center gap-2 mb-1">
            <Clock size={18} className="text-blue-600" />
            <span className="text-sm text-blue-600">Pending</span>
          </div>
          <p className="text-2xl font-bold text-blue-700">{pendingCount}</p>
        </div>

        <div className="bg-amber-50 rounded-lg p-4">
          <div className="flex items-center gap-2 mb-1">
            <Clock size={18} className="text-amber-600" />
            <span className="text-sm text-amber-600">In Progress</span>
          </div>
          <p className="text-2xl font-bold text-amber-700">{inProgressCount}</p>
        </div>

        <div className="bg-emerald-50 rounded-lg p-4">
          <div className="flex items-center gap-2 mb-1">
            <CheckCircle2 size={18} className="text-emerald-600" />
            <span className="text-sm text-emerald-600">Completed</span>
          </div>
          <p className="text-2xl font-bold text-emerald-700">{completedCount}</p>
        </div>
      </div>

      {getReaderStats().length > 0 && (
        <div>
          <h3 className="text-sm font-semibold text-gray-700 mb-3 flex items-center gap-2">
            <User size={16} />
            Reader Progress
          </h3>
          <div className="space-y-2">
            {getReaderStats().map((stat, index) => (
              <div key={index} className="flex items-center justify-between p-2 bg-gray-50 rounded">
                <span className="text-sm font-medium text-gray-700">{stat.name}</span>
                <span className="text-sm text-gray-600">
                  {stat.completed} / {stat.total} completed
                </span>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
