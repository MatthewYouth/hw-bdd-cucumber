Given(/^the following movies exist:$/) do |movies_table|
  movies_table.hashes.each do |movie|
    Movie.create!(movie)
  end
end

Then(/^(\d+) seed movies should exist$/) do |n_seeds|
  expect(Movie.count).to eq n_seeds.to_i
end

Then(/^I should see "(.*)" before "(.*)" in the movie list$/) do |first_title, second_title|
  titles = all('#movies > div[id^="movie_"] > p:first-child').map do |element|
    element.text.sub(/\ATitle:\s*/, '').strip
  end

  # Verify both titles exist before comparing their positions.
  expect(titles).to include(first_title, second_title)
  expect(titles.index(first_title)).to be < titles.index(second_title)
end

When(/^I check the following ratings: (.*)$/) do |rating_list|
  rating_list.split(',').map(&:strip).each do |rating|
    check(rating)
  end
end

Then(/^I should (not )?see the following movies: (.*)$/) do |no, movie_list|
  within('#movies') do
    movie_list.split(',').map(&:strip).each do |title|
      if no
        expect(page).not_to have_content(title)
      else
        expect(page).to have_content(title)
      end
    end
  end
end

Then(/^I should see all the movies$/) do
  # The index renders one movie partial per div, rather than table rows.
  expect(page).to have_css('#movies > div[id^="movie_"]', count: Movie.count)
  within('#movies') do
    Movie.pluck(:title).each do |title|
      expect(page).to have_content(title)
    end
  end
end
