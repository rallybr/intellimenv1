-- Script para verificar e corrigir a constraint de status na tabela user_quizzes
-- Execute este script no seu banco Supabase

-- 1. Verificar se existe a constraint
SELECT 
    conname as constraint_name,
    pg_get_constraintdef(oid) as constraint_definition
FROM pg_constraint 
WHERE conrelid = 'user_quizzes'::regclass 
  AND conname LIKE '%status%';

-- 2. Se a constraint existir, vamos removê-la primeiro
ALTER TABLE user_quizzes DROP CONSTRAINT IF EXISTS user_quizzes_status_check;

-- 3. Criar a constraint correta com todos os valores válidos
ALTER TABLE user_quizzes 
ADD CONSTRAINT user_quizzes_status_check 
CHECK (status IN ('pending_invite', 'waiting_partner', 'in_progress', 'completed', 'abandoned'));

-- 4. Verificar se a constraint foi criada corretamente
SELECT 
    conname as constraint_name,
    pg_get_constraintdef(oid) as constraint_definition
FROM pg_constraint 
WHERE conrelid = 'user_quizzes'::regclass 
  AND conname = 'user_quizzes_status_check';

-- 5. Verificar os valores atuais de status na tabela
SELECT DISTINCT status, COUNT(*) as count
FROM user_quizzes 
GROUP BY status
ORDER BY status; 