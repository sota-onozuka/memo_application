class Memo
  class << self
    def create(title: memo_title, content: memo_content)
      connection = PG.connect( dbname: 'memos')
      connection.exec( "INSERT INTO note(title, content) VALUES ('#{title}', '#{content}')" )
    end
  end
end