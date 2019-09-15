require_relative "./test_case"

class Teams::RejectInviteTest < Teams::TestCase
  test "user rejects invite" do
    user = create(:user, :onboarded, email: "test@example.com")
    team = create(:team, name: "Team A")
    create(:team_invitation, team: team, email: "test@example.com")

    sign_in!(user)
    visit teams_teams_path
    accept_confirm do
      click_on "Reject"
    end

    assert page.has_no_content?("Team A")
  end
end
