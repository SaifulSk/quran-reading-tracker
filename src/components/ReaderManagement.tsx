import { useState } from 'react';
import { UserPlus, X, Trash2 } from 'lucide-react';
import { supabase, Reader } from '../lib/supabase';

type ReaderManagementProps = {
  readers: Reader[];
  organizationId: string | null;
  onReaderAdded: () => void;
  onReaderRemoved: () => void;
};

const READER_COLORS = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#FFA07A', '#98D8C8', '#F7DC6F', '#BB8FCE', '#85C1E2', '#F8B88B', '#A8D5BA'];

export function ReaderManagement({ readers, organizationId, onReaderAdded, onReaderRemoved }: ReaderManagementProps) {
  const [isAdding, setIsAdding] = useState(false);
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [color, setColor] = useState('');
  const [loading, setLoading] = useState(false);

  const usedColors = new Set(readers.map(r => r.color));
  const availableColors = READER_COLORS.filter(c => !usedColors.has(c));
  const nextColor = availableColors.length > 0 ? availableColors[0] : READER_COLORS[0];

  const handleAddReader = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim() || !organizationId) return;

    setLoading(true);
    try {
      const selectedColor = color || nextColor;
      const { error } = await supabase
        .from('readers')
        .insert([{ name: name.trim(), email: email.trim() || null, color: selectedColor, organization_id: organizationId }]);

      if (error) throw error;

      setName('');
      setEmail('');
      setColor('');
      setIsAdding(false);
      onReaderAdded();
    } catch (error) {
      console.error('Error adding reader:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleRemoveReader = async (readerId: string) => {
    if (!confirm('Are you sure you want to remove this reader? All their assignments will be deleted.')) {
      return;
    }

    try {
      const { error } = await supabase
        .from('readers')
        .delete()
        .eq('id', readerId);

      if (error) throw error;
      onReaderRemoved();
    } catch (error) {
      console.error('Error removing reader:', error);
    }
  };

  const handleRemoveAllReaders = async () => {
    if (!confirm('Are you sure you want to remove all readers? All their assignments will be deleted. This cannot be undone.')) {
      return;
    }

    try {
      const { error } = await supabase
        .from('readers')
        .delete()
        .neq('id', '00000000-0000-0000-0000-000000000000');

      if (error) throw error;
      onReaderRemoved();
    } catch (error) {
      console.error('Error removing all readers:', error);
    }
  };

  return (
    <div className="bg-white rounded-lg shadow-md p-6">
      <div className="flex items-center justify-between mb-4">
        <h2 className="text-xl font-semibold text-gray-800 mr-2">Readers</h2>
        <div className="flex items-center gap-2">
          <button
            onClick={() => setIsAdding(!isAdding)}
            className="flex items-center gap-2 px-4 py-2 bg-emerald-600 text-white rounded-lg hover:bg-emerald-700 transition-colors"
          >
            <UserPlus size={20} />
            Add
          </button>
          {readers.length > 0 && (
            <button
              onClick={handleRemoveAllReaders}
              className="flex items-center gap-2 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
            >
              <Trash2 size={20} />
              Clear
            </button>
          )}
        </div>
      </div>

      {isAdding && (
        <form onSubmit={handleAddReader} className="mb-4 p-4 bg-gray-50 rounded-lg">
          <div className="space-y-3">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Name *
              </label>
              <input
                type="text"
                value={name}
                onChange={(e) => setName(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-emerald-500"
                required
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Color
              </label>
              <div className="flex gap-2 flex-wrap">
                {READER_COLORS.map((c) => {
                  const isAvailable = availableColors.includes(c);
                  return (
                    <button
                      key={c}
                      type="button"
                      onClick={() => isAvailable && setColor(c)}
                      disabled={!isAvailable}
                      className={`w-8 h-8 rounded-full border-2 transition-transform ${
                        color === c ? 'border-gray-800 scale-110' : 'border-gray-300'
                      } ${!isAvailable ? 'opacity-30 cursor-not-allowed' : 'cursor-pointer'}`}
                      style={{ backgroundColor: c }}
                      title={isAvailable ? 'Click to select' : 'Already assigned'}
                    />
                  );
                })}
              </div>
            </div>
            <div className="flex gap-2">
              <button
                type="submit"
                disabled={loading}
                className="px-4 py-2 bg-emerald-600 text-white rounded-md hover:bg-emerald-700 disabled:opacity-50"
              >
                {loading ? 'Adding...' : 'Add'}
              </button>
              <button
                type="button"
                onClick={() => {
                  setIsAdding(false);
                  setName('');
                  setEmail('');
                  setColor('');
                }}
                className="px-4 py-2 bg-gray-300 text-gray-700 rounded-md hover:bg-gray-400"
              >
                Cancel
              </button>
            </div>
          </div>
        </form>
      )}

      <div className="space-y-2">
        {readers.length === 0 ? (
          <p className="text-gray-500 text-center py-4">No readers added yet</p>
        ) : (
          readers.map((reader) => (
            <div
              key={reader.id}
              className="flex items-center justify-between p-3 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors"
            >
              <div className="flex items-center gap-3">
                <div
                  className="w-5 h-5 rounded-full border-2 border-gray-300"
                  style={{ backgroundColor: reader.color }}
                />
                <div>
                  <p className="font-medium text-gray-800">{reader.name}</p>
                  {reader.email && <p className="text-sm text-gray-500">{reader.email}</p>}
                </div>
              </div>
              <button
                onClick={() => handleRemoveReader(reader.id)}
                className="p-2 text-red-600 hover:bg-red-50 rounded-md transition-colors"
              >
                <X size={18} />
              </button>
            </div>
          ))
        )}
      </div>
    </div>
  );
}
