-- Script para adicionar o campo updated_at na tabela user_quizzes
-- Execute este script no seu banco Supabase

-- 1. Adicionar o campo updated_at
ALTER TABLE user_quizzes 
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE;

-- 2. Atualizar registros existentes para ter o campo updated_at
UPDATE user_quizzes 
SET updated_at = created_at 
WHERE updated_at IS NULL;

-- 3. Criar índice para melhorar performance das consultas por updated_at
CREATE INDEX IF NOT EXISTS idx_user_quizzes_updated_at ON user_quizzes(updated_at);

-- 4. Verificar se o campo foi adicionado corretamente
SELECT 
    column_name, 
    data_type, 
    is_nullable, 
    column_default
FROM information_schema.columns 
WHERE table_name = 'user_quizzes' 
  AND column_name = 'updated_at';

-- 5. Comentário para documentar o novo campo
COMMENT ON COLUMN user_quizzes.updated_at IS 'Timestamp da última atualização da pontuação em tempo real'; 