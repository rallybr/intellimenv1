-- Script para atualizar a estrutura da tabela user_quizzes para suportar sincronização em tempo real
-- Execute este script no seu banco Supabase

-- 1. Adicionar novos campos à tabela user_quizzes
ALTER TABLE user_quizzes 
ADD COLUMN IF NOT EXISTS is_ready BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS ready_at TIMESTAMP WITH TIME ZONE;

-- 2. Atualizar registros existentes para ter os novos campos
UPDATE user_quizzes 
SET is_ready = FALSE 
WHERE is_ready IS NULL;

-- 3. Atualizar status de quizzes duplos existentes para o novo fluxo
-- Quizzes com partner_id que estão 'in_progress' devem ser 'waiting_partner'
UPDATE user_quizzes 
SET status = 'waiting_partner' 
WHERE partner_id IS NOT NULL 
  AND status = 'in_progress' 
  AND is_ready = FALSE;

-- 4. Criar índices para melhorar performance das consultas em tempo real
CREATE INDEX IF NOT EXISTS idx_user_quizzes_quiz_id ON user_quizzes(quiz_id);
CREATE INDEX IF NOT EXISTS idx_user_quizzes_user_id ON user_quizzes(user_id);
CREATE INDEX IF NOT EXISTS idx_user_quizzes_partner_id ON user_quizzes(partner_id);
CREATE INDEX IF NOT EXISTS idx_user_quizzes_status ON user_quizzes(status);
CREATE INDEX IF NOT EXISTS idx_user_quizzes_is_ready ON user_quizzes(is_ready);

-- 5. Criar função para verificar se ambos os parceiros estão prontos
CREATE OR REPLACE FUNCTION check_both_partners_ready(quiz_id_param UUID)
RETURNS BOOLEAN AS $$
DECLARE
    partner1_ready BOOLEAN;
    partner2_ready BOOLEAN;
BEGIN
    -- Buscar status de ambos os usuários para o quiz
    SELECT is_ready INTO partner1_ready
    FROM user_quizzes 
    WHERE quiz_id = quiz_id_param 
    LIMIT 1;
    
    SELECT is_ready INTO partner2_ready
    FROM user_quizzes 
    WHERE quiz_id = quiz_id_param 
    AND user_id != (SELECT user_id FROM user_quizzes WHERE quiz_id = quiz_id_param LIMIT 1)
    LIMIT 1;
    
    -- Retornar true se ambos estiverem prontos
    RETURN COALESCE(partner1_ready, FALSE) AND COALESCE(partner2_ready, FALSE);
END;
$$ LANGUAGE plpgsql;

-- 6. Criar trigger para atualizar status automaticamente quando ambos estiverem prontos
CREATE OR REPLACE FUNCTION update_quiz_status_on_ready()
RETURNS TRIGGER AS $$
BEGIN
    -- Se o usuário foi marcado como pronto
    IF NEW.is_ready = TRUE AND OLD.is_ready = FALSE THEN
        -- Verificar se ambos os parceiros estão prontos
        IF check_both_partners_ready(NEW.quiz_id) THEN
            -- Atualizar status para 'in_progress' para ambos os usuários
            UPDATE user_quizzes 
            SET status = 'in_progress'
            WHERE quiz_id = NEW.quiz_id;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criar o trigger
DROP TRIGGER IF EXISTS trigger_update_quiz_status ON user_quizzes;
CREATE TRIGGER trigger_update_quiz_status
    AFTER UPDATE ON user_quizzes
    FOR EACH ROW
    EXECUTE FUNCTION update_quiz_status_on_ready();

-- 7. Configurar Row Level Security (RLS) para user_quizzes se ainda não estiver configurado
ALTER TABLE user_quizzes ENABLE ROW LEVEL SECURITY;

-- Remover políticas existentes se houver (para evitar conflitos)
DROP POLICY IF EXISTS "Users can view their own quizzes and partner quizzes" ON user_quizzes;
DROP POLICY IF EXISTS "Users can insert their own quizzes" ON user_quizzes;
DROP POLICY IF EXISTS "Users can update their own quizzes" ON user_quizzes;
DROP POLICY IF EXISTS "Users can delete their own quizzes" ON user_quizzes;

-- Política para usuários verem seus próprios quizzes e quizzes onde são parceiros
CREATE POLICY "Users can view their own quizzes and partner quizzes" ON user_quizzes
    FOR SELECT USING (
        auth.uid() = user_id OR 
        auth.uid() = partner_id
    );

-- Política para usuários inserirem seus próprios quizzes
CREATE POLICY "Users can insert their own quizzes" ON user_quizzes
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Política para usuários atualizarem seus próprios quizzes
CREATE POLICY "Users can update their own quizzes" ON user_quizzes
    FOR UPDATE USING (auth.uid() = user_id);

-- Política para usuários deletarem seus próprios quizzes
CREATE POLICY "Users can delete their own quizzes" ON user_quizzes
    FOR DELETE USING (auth.uid() = user_id);

-- 8. Comentários para documentar os novos campos
COMMENT ON COLUMN user_quizzes.is_ready IS 'Indica se o usuário está pronto para começar o quiz duplo';
COMMENT ON COLUMN user_quizzes.ready_at IS 'Timestamp de quando o usuário ficou pronto';
COMMENT ON COLUMN user_quizzes.status IS 'Status do quiz: pending_invite, waiting_partner, in_progress, completed, abandoned';

-- 9. Verificar se as alterações foram aplicadas
SELECT 
    column_name, 
    data_type, 
    is_nullable, 
    column_default
FROM information_schema.columns 
WHERE table_name = 'user_quizzes' 
  AND column_name IN ('is_ready', 'ready_at', 'status')
ORDER BY column_name; 