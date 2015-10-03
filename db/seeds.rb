# UserMember
def create_seed(date, table_name)
  path = Rails.root.join('db', 'seeds', "#{date}_#{table_name}.rb")
  if File.exist?(path)
    puts "■■■■Creating #{table_name}...."
    require(path)
  end
end

create_seed('20151003', 'subject_template_type')
create_seed('20151003', 'subject_template')
