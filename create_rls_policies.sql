-- Políticas RLS para a tabela user_quizzes
-- Este arquivo contém as políticas necessárias para permitir que usuários autenticados
-- possam inserir, atualizar e visualizar seus próprios registros de quiz

-- 1. Política para permitir inserção de registros próprios
CREATE POLICY "Users can insert their own quiz records" ON "public"."user_quizzes"
FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 2. Política para permitir atualização de registros próprios
CREATE POLICY "Users can update their own quiz records" ON "public"."user_quizzes"
FOR UPDATE USING (auth.uid() = user_id);

-- 3. Política para permitir visualização de registros próprios
CREATE POLICY "Users can view their own quiz records" ON "public"."user_quizzes"
FOR SELECT USING (auth.uid() = user_id);

-- 4. Política para permitir visualização de registros onde o usuário é parceiro
CREATE POLICY "Users can view records where they are partner" ON "public"."user_quizzes"
FOR SELECT USING (auth.uid() = partner_id);

-- 5. Política para permitir visualização de todos os registros (para administradores)
-- Descomente se necessário para administradores
-- CREATE POLICY "Admins can view all quiz records" ON "public"."user_quizzes"
-- FOR SELECT USING (
--   EXISTS (
--     SELECT 1 FROM users 
--     WHERE users.id = auth.uid() 
--     AND users.access_level IN ('adm', 'editor', 'moderador')
--   )
-- );

-- 6. Política para permitir exclusão de registros próprios (opcional)
-- CREATE POLICY "Users can delete their own quiz records" ON "public"."user_quizzes"
-- FOR DELETE USING (auth.uid() = user_id);

-- Verificar se as políticas foram criadas corretamente
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'user_quizzes'; 