# Use official Ruby image
FROM ruby:3.4.3

# Set working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install dependencies
# RUN bundle install
RUN gem install bundler && bundle install

# Copy the rest of the application code
COPY . .

# Set default command (can be overridden)
CMD ["ruby", "runner.rb"] 