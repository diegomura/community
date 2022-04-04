"""
Applet: World Clock
Summary: Multi timezone clock
Description: Displays the time in up to three different locations.
Author: Elliot Bentley
"""

load("render.star", "render")
load("time.star", "time")
load("schema.star", "schema")
load("encoding/json.star", "json")
load("sunrise.star", "sunrise")

number_font = "tom-thumb"
font = "tom-thumb"

def main(config):
    if (config.get("location_1")):
        locations = [
            json.decode(config.get("location_1")),
            json.decode(config.get("location_2")),
            json.decode(config.get("location_3")),
        ]
    else:
        locations = [
            {"timezone": "America/New_York", "locality": "New York", "lat": 0, "lng": 0},
            {"timezone": "Europe/London", "locality": "London", "lat": 0, "lng": 0},
            {"timezone": "Asia/Tokyo", "locality": "Tokyo", "lat": 35.703286, "lng": 139.748475},
        ]

    horizonal_rule = render.Box(
        height = 1,
        color = "#555",
    )

    rows = []

    i = 0
    for location in locations:
        i += 1

        timezone = location["timezone"]
        locality = config.get("location_%s_label" % i)
        if (not locality):
            locality = location["locality"]

        now = time.now().in_location(timezone)

        lat, lng = float(location["lat"]), float(location["lng"])
        rise = sunrise.sunrise(lat, lng, now)
        set = sunrise.sunset(lat, lng, now)
        is_daytime = now > rise and now < set

        time_color = "#bbbbbb"

        if (config.get("color_by_daylight") != "false"):
            if (is_daytime):
                time_color = "#ffe9ad"
            else:
                time_color = "#94a0ff"

        location_name = render.Box(
            height = 7,
            width = 43,
            child = render.Padding(
                pad = (4, 0, 0, 0),
                child = render.Marquee(
                    width = 43,
                    child = render.Text(
                        content = locality,
                        font = font,
                        color = time_color,
                        offset = -1,
                    ),
                ),
            ),
        )

        location_time = render.Box(
            child = render.Padding(
                pad = (0, 1, 0, 1),
                child = render.Row(
                    children = [
                        render.Text(
                            content = now.format("15"),
                            font = number_font,
                            color = "#ffffff",
                        ),
                        render.Box(
                            width = 2,
                            child = render.Animation(
                                children = [
                                    render.Text(
                                        content = ":",
                                        font = "CG-pixel-3x5-mono",
                                        color = "#777777",
                                        offset = 0,
                                    ),
                                    render.Text(
                                        content = " ",
                                        font = "CG-pixel-3x5-mono",
                                    ),
                                ],
                            ),
                        ),
                        render.Text(
                            content = now.format("04"),
                            font = number_font,
                            color = "#ffffff",
                        ),
                    ],
                ),
            ),
            width = 23,
            height = 7,
        )

        row = render.Row(
            main_align = "start",
            children = [
                location_name,
                location_time,
            ],
        )
        rows.append(row)
        if (i < len(locations)):
            rows.append(horizonal_rule)

    return render.Root(
        delay = 500,
        child = render.Column(
            children = rows,
            main_align = "space_around",
            expanded = True,
        ),
    )

def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.Location(
                id = "location_1",
                name = "Location 1",
                desc = "Location for which to display time.",
                icon = "place",
            ),
            schema.Text(
                id = "location_1_label",
                name = "Location 1 label",
                desc = "Custom label (optional)",
                icon = "tag",
                default = "",
            ),
            schema.Location(
                id = "location_2",
                name = "Location 2",
                desc = "Location for which to display time.",
                icon = "place",
            ),
            schema.Text(
                id = "location_2_label",
                name = "Location 2 label",
                desc = "Custom label (optional)",
                icon = "tag",
                default = "",
            ),
            schema.Location(
                id = "location_3",
                name = "Location 3",
                desc = "Location for which to display time.",
                icon = "place",
            ),
            schema.Text(
                id = "location_3_label",
                name = "Location 3 label",
                desc = "Custom label (optional)",
                icon = "tag",
                default = "",
            ),
            schema.Toggle(
                id = "color_by_daylight",
                name = "Color by daylight",
                desc = "Adjust location name color based on time of day.",
                icon = "sun",
                default = True,
            ),
        ],
    )