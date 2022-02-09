# ----------------------------------------------------------------------------------------
#                                        Dockerfile
# ----------------------------------------------------------------------------------------
# image:       plugfox/plugfox-badges-faas
# repository:  https://github.com/plugfox/plugfox-badges-faas
# license:     MIT
# requires:
# + dart:stable
# authors:
# + Plague Fox <PlugFox@gmail.com>
# ----------------------------------------------------------------------------------------


FROM dart:stable AS build

# Resolve app dependencies.
WORKDIR /app
COPY pubspec.* ./
RUN dart pub get

# Copy app source code and AOT compile it.
COPY . .
# Ensure packages are still up-to-date if anything has changed
RUN dart pub get --offline
RUN dart pub run build_runner build --delete-conflicting-outputs
RUN dart compile exe bin/server.dart -o bin/server

# Build minimal serving image from AOT-compiled `/server` and required system
# libraries and configuration files stored in `/runtime/` from the build stage.
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/bin/server /app/bin/

# Add lables
LABEL name="plugfox/plugfox-badges-faas" \
      description="Plugfox Badges FaaS" \
      license="MIT" \
      vcs-type="git" \
      vcs-url="https://github.com/plugfox/plugfox-badges-faas" \
      github="https://github.com/plugfox/plugfox-badges-faas" \
      maintainer="Plague Fox <plugfox@gmail.com>" \
      authors="@PlugFox" \
      family="plugfox/plugfox-badges-faas"

# Start server.
EXPOSE 8080

ENTRYPOINT ["/app/bin/server", "--signature-type=cloudevent"]