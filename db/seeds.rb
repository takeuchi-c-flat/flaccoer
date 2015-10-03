# UserMember
def create_seed(table_name, seq_number)
  path = Rails.root.join('db', 'seeds', "#{table_name}_#{seq_number}.rb")
  if File.exist?(path)
    puts "■Creating #{table_name}...."
    require(path)
  end
end

create_seed('subject_template_type', '001')
create_seed('subject_template', '001')
