import { useEffect, useState } from 'react';
import { User } from '@supabase/supabase-js';
import { supabase } from '../lib/supabase';

export function useAuth() {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const getSession = async () => {
      try {
        const { data: { session } } = await supabase.auth.getSession();
        setUser(session?.user ?? null);
      } catch (err) {
        console.error('Error getting session:', err);
      } finally {
        setLoading(false);
      }
    };

    getSession();

    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      setUser(session?.user ?? null);
    });

    return () => subscription?.unsubscribe();
  }, []);

  const signUp = async (email: string, password: string, name: string) => {
    try {
      setError(null);
      const { data, error: signUpError } = await supabase.auth.signUp({
        email,
        password,
        options: {
          data: { full_name: name }
        }
      });

      if (signUpError) {
        setError(signUpError.message);
        return null;
      }

      return data.user;
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Signup failed';
      setError(message);
      return null;
    }
  };

  const signIn = async (email: string, password: string) => {
    try {
      setError(null);
      const { data, error: signInError } = await supabase.auth.signInWithPassword({
        email,
        password,
      });

      if (signInError) {
        setError(signInError.message);
        return null;
      }

      return data.user;
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Login failed';
      setError(message);
      return null;
    }
  };

  const signOut = async () => {
    try {
      setError(null);
      const { error: signOutError } = await supabase.auth.signOut();
      if (signOutError) throw signOutError;
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Logout failed';
      setError(message);
    }
  };

  return { user, loading, error, signUp, signIn, signOut, setError };
}
