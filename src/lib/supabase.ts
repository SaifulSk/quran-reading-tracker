import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

export type Reader = {
  id: string;
  name: string;
  email: string | null;
  color: string;
  created_at: string;
};

export type Chapter = {
  id: number;
  name: string;
  created_at: string;
};

export type Assignment = {
  id: string;
  reader_id: string;
  chapter_id: number;
  status: 'pending' | 'in_progress' | 'completed';
  assigned_at: string;
  completed_at: string | null;
  notes: string | null;
};

export type AssignmentWithDetails = Assignment & {
  readers: Reader;
  chapters: Chapter;
};
