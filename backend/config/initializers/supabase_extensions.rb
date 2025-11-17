# Handle Supabase-specific PostgreSQL extensions
# These extensions are available in Supabase production but not in standard PostgreSQL
# This initializer ensures they're handled gracefully in all environments

# Note: The schema.rb file only includes 'plpgsql' to maintain compatibility.
# Supabase-specific extensions (pg_graphql, supabase_vault) are handled separately.

# In production, ensure Supabase extensions are enabled after connection
# This is a safety check - Supabase should have them enabled by default
if Rails.env.production?
  Rails.application.config.after_initialize do
    begin
      ActiveRecord::Base.connection_pool.with_connection do |connection|
        # These should already exist in Supabase, but ensure they're enabled
        %w[pg_graphql supabase_vault pg_stat_statements pgcrypto uuid-ossp].each do |ext|
          begin
            connection.execute("CREATE EXTENSION IF NOT EXISTS #{ext}")
            Rails.logger.debug "Verified #{ext} extension is enabled"
          rescue => e
            # Log but don't fail - extensions might be managed by Supabase
            Rails.logger.warn "Could not enable #{ext} extension (may already exist or be managed): #{e.message}"
          end
        end
      end
    rescue => e
      Rails.logger.warn "Could not verify Supabase extensions: #{e.message}"
    end
  end
end
