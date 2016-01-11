require 'octokit'
require 'csv'
require 'pry'

client = Octokit::Client.new(login: ENV['GITHUB_USERNAME'], password: ENV['GITHUB_PASSWORD'])

issue_status = ARGV[0]
repo = ARGV[1]
time = Time.now.strftime("%L")

# csv = CSV.new(File.open("closed_github_issues_at_#{time}.csv", 'w'))
csv = CSV.new(File.open("#{issue_status}_github_issues.csv", 'w'))

headers = [
  "title",
  "issue_body",
  "id",
  "github_user",
]

csv << headers

temp_issues = []
issues = []
ticket = []
page = 0

puts "Examining issues from GitHub..."
begin
  page = page + 1
  binding.pry
  temp_issues = client.list_issues(repo, state: issue_status, page: page)
  temp_issues.each do |t|
    comments = client.issue_comments(repo, t.number)
    if comments.any?
      comments.each do |c|
        comment = "Reported by " + c[:user][:login] + c[:created_at].strftime(" on %B %e, %Y") + "\r" + c[:body]
        ticket << t[:title]
        ticket << comment
        ticket << t[:id]
        ticket << t[:user][:login]
        issues << ticket
        ticket = []
      end
    end
  end
  puts "Page #{page} complete"
end while not temp_issues.empty?


def the_message(issues)
  issues.count == 1 ? word = "issue" : "issues"
  "#{issues.count} #{word}"
end

puts "Processing #{the_message(issues)}..."

issues.each do |issue|
  issue.to_s.split(',')
  row = [
    issue[0],
    issue[1],
    issue[2],
    issue[3]
  ]
  csv << row
end

puts "Completed!"
