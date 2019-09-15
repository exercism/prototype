require_relative "./test_case"

class Teams::RemoveMemberTest < Teams::TestCase
  test "team admin removes member from team" do
    team_admin = create(:user, :onboarded)
    team = create(:team)
    member = create(:user, :onboarded, name: "Team member")
    create(:team_membership, team: team, user: team_admin, admin: true)
    create(:team_membership, team: team, user: member, admin: false)

    sign_in!(team_admin)
    visit teams_team_memberships_path(team)
    accept_confirm do
      click_on "Remove"
    end

    assert page.has_no_content?("Team member")
  end
end
