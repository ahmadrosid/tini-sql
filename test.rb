describe 'database' do
  def run_script(commands)
    raw_output = nil
    IO.popen("./tiny-sql", "r+") do |pipe|
      commands.each do |command|
        pipe.puts command
      end

      pipe.close_write

      # Read entire output
      raw_output = pipe.gets(nil)
    end
    raw_output.split("\n")
  end

  it 'inserts and retrieves a row' do
    result = run_script([
      "insert 1 user1 person1@example.com",
      "select",
      ".exit",
    ])
    expect(result).to match_array([
      "tiny-sql> Executed.",
      "tiny-sql> (1, user1, person1@example.com)",
      "Executed.",
      "tiny-sql> ",
    ])
  end

  it 'print error message when table is full' do
    script = (1..1501) .map do |i|
      "insert #{i} user#{i} person#{i}@example.com"
    end
    script << ".exit"
    result = run_script(script)
    expect(result[-2]).to eq("tiny-sql> Error: table full.")
  end

  it 'allows inserting strings that are the maximum length' do
    log_username = "a"*32
    log_email = "a"*255
    script = [
      "insert 1 #{log_username} #{log_email}",
      "select",
      ".exit",
    ]
    puts "\n"
    puts script
    puts "\n"
    result = run_script(script)
    expect(result).to match_array([
      "tiny-sql> Executed.",
      "tiny-sql> (1, #{log_username}, #{log_email})",
      "Executed.",
      "tiny-sql> ",
    ])
  end
end

