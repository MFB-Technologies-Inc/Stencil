// Fixtures+Huge.swift
// Stencil
//
// Copyright (c) 2022, Kyle Fuller
// All rights reserved.
//
// Copyright 2024 MFB Technologies, Inc.
//
// This source code is licensed under the BSD-2-Clause License found in the
// LICENSE file in the root directory of this source tree.

extension Fixtures {
    static let huge = """
    <!DOCTYPE html>
    <html lang="nl">
    <head>
        <title>{% block title %}Rond De Tafel
            {% if sort == "new" %}
                {{ block.super }} - Nieuwste spellen
            {% elif sort == "upcoming" %}
                {{ block.super }} - Binnenkort op de agenda
            {% elif sort == "near-me" %}
                {{ block.super }} - In mijn buurt
            {% endif %}
        {% endblock %}</title>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
        <meta name="author" content="Steven Van Impe">
        <meta name="description" content="Rond De Tafel brengt mensen en spellen samen. Vind spellen, zoek medespelers en maak nieuwe vrienden.">
        <meta property="og:site_name" content="Rond De Tafel">
        <meta property="og:type" content="website">
        <meta property="fb:app_id" content="{{ base.facebook.app }}">
        <meta property="og:description" content="Rond De Tafel brengt mensen en spellen samen. Vind spellen, zoek medespelers en maak nieuwe vrienden.">
        <meta property="og:url" content="{{ base.opengraph.url }}">
        {% block opengraph %}
            <meta property="og:title" content="Rond De tafel">
            <meta property="og:image" content="{{ base.opengraph.image }}">
        {% endblock %}
        <link href="/public/img/favicon.png" rel="icon" type="image/png">
        <link href="/public/css/bootstrap.min.css" rel="stylesheet">
        <link href="/public/css/font-awesome.min.css" rel="stylesheet">
        <link href="/public/css/pikaday.min.css" rel="stylesheet">
        <style>
            .navbar, .btn-primary {
                background-color: #2185D0;
            }
            h2, h3 {
                margin-bottom: 1rem;
            }
            img.avatar {
                width: 40px;
                height: 40px;
            }
            /* Pagination, used for sort and view options. */
            .page-link {
                color: #2185D0;
            }
            .page-item.active .page-link {
                background-color: #2185D0;
                border-color: #2185D0;
            }
            /* Activity cards, used in grid view. */
            a.card {
                width: 100%;
                color: inherit;
                text-decoration: none;
            }
            a.card.green {
                box-shadow: 0 1px 0 0 #21BA45;
            }
            a.card.yellow {
                box-shadow: 0 1px 0 0 #FBBD08;
            }
            a.card.red {
                box-shadow: 0 1px 0 0 #DB2828;
            }
            a.card .card-body {
                line-height: 2em;
            }
            /* Activity items, used in list view. */
            a.item {
                display: flex;
                color: inherit;
                text-decoration: none;
                border-radius: 0.25rem;
                margin-bottom: 1rem;
            }
            a.item:focus, a.item:hover {
                background-color: #f8f9fa;
            }
            a.item.green {
                box-shadow: 1px 0 0 0 #21BA45;
            }
            a.item.yellow {
                box-shadow: 1px 0 0 0 #FBBD08;
            }
            a.item.red {
                box-shadow: 1px 0 0 0 #DB2828;
            }
            a.item .body {
                display: flex;
                flex-direction: column;
                margin-left: 1rem;
                line-height: 2em;
            }
            @media(min-width:768px) {
                a.item.autoborder {
                    border: 1px solid rgba(0, 0, 0, 0.125);
                }
                a.item.autoborder .body {
                    margin-top: 0.5rem;
                }
            }
            /* Conversations and messages */
            a.conversation {
                display: flex;
                color: inherit;
                text-decoration: none;
            }
            a.conversation .body {
                display: flex;
                flex-direction: column;
                margin-left: 1rem;
            }
            @media(min-width:768px) {
                .messages {
                    margin-left: 2rem;
                }
            }
            /* Margins for icons */
            .fa-calendar, .fa-clock-o, .fa-envelope, .fa-hourglass-o, .fa-map-marker, .fa-user, .fa-users {
                margin-right: 0.25rem;
            }
            .fa-home {
                margin-left: 0.25rem;
            }
            /* Don't use margins in input groups or buttons */
            button > i.fa, .input-group-text > i.fa {
                margin-right: 0;
            }
            .fa-facebook-official {
                color: #29487d;
            }
        </style>
        <!-- jQuery is included in head because it's used by included components in body. -->
        <script src="/public/js/jquery.min.js"></script>
        {% block additional-head %}{% endblock %}
    </head>
    <body>
        <!-- Collapsed navbar -->
        <nav class="d-md-none navbar navbar-dark">
            <a class="navbar-brand" href="/web/home">Rond De Tafel</a>
            <ul class="navbar-nav ml-auto mr-3">
                {% if base.unreadMessageCount > 0 %}
                    <li class="nav-item">
                        <a class="nav-link" href="/web/user/messages">
                            <i class="fa fa-envelope"></i>
                        </a>
                    </li>
                {% endif %}
            </ul>
            <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarResponsive">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarResponsive">
                <ul class="navbar-nav">
                    <li class="nav-item">
                        <a class="nav-link" href="/web/activities">Spellen</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="/web/host">Organiseer</a>
                    </li>
                    {% if base.user %}
                        <li class="nav-item">
                            <a class="nav-link" href="/web/user/activities">Mijn spellen</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="/web/user/messages">
                                Berichten
                                {% if base.unreadMessageCount > 0 %}
                                    ({{ base.unreadMessageCount }})
                                {% endif %}
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="/web/user/settings">Instellingen</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="/authentication/signout">Afmelden</a>
                        </li>
                    {% else %}
                        <li class="nav-item">
                            <!-- The href will be set in code -->
                            <a class="global-signin nav-link" href="#">Aanmelden</a>
                        </li>
                    {% endif %}
                    <li class="nav-item">
                        <a class="nav-link" href="/web/faq">Help</a>
                    </li>
                </ul>
            </div>
        </nav>
        <!-- Full navbar -->
        <nav class="d-none d-md-flex navbar navbar-expand navbar-dark">
            <a class="navbar-brand" href="/web/home">Rond De Tafel</a>
            <ul class="navbar-nav mr-auto">
                <li class="nav-item">
                    <a class="nav-link" href="/web/activities">Spellen</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="/web/host">Organiseer</a>
                </li>
            </ul>
            <ul class="navbar-nav">
                {% if base.user %}
                    {% if base.unreadMessageCount > 0 %}
                        <li class="nav-item">
                            <a class="nav-link" href="/web/user/messages">
                                <i class="fa fa-envelope"></i>
                            </a>
                        </li>
                    {% endif %}
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" data-toggle="dropdown">
                            {{ base.user.name }}
                        </a>
                        <div class="dropdown-menu dropdown-menu-right">
                            <a class="dropdown-item" href="/web/user/activities">Mijn spellen</a>
                            <a class="dropdown-item" href="/web/user/messages">
                                Berichten
                                {% if base.unreadMessageCount > 0 %}
                                    ({{ base.unreadMessageCount }})
                                {% endif %}
                            </a>
                            <a class="dropdown-item" href="/web/user/settings">Instellingen</a>
                            <a class="dropdown-item" href="/authentication/signout">Afmelden</a>
                        </div>
                    </li>
                {% else %}
                    <li class="nav-item">
                        <!-- The href will be set in code -->
                        <a class="global-signin nav-link" href="#">Aanmelden</a>
                    </li>
                {% endif %}
                <li class="nav-item">
                    <a class="nav-link" href="/web/faq">
                        <i class="fa fa-question-circle fa-lg"></i>
                    </a>
                </li>
            </ul>
        </nav>
        <!-- Main content -->
        <div class="container mt-3">
    <div class="d-flex justify-content-center">
        <!-- Sort options -->
        <ul class="pagination mr-md-5">
            {% if sort == "new" %}
                <li class="page-item active">
                    <span class="page-link">
                        <i class="fa fa-asterisk d-none d-sm-inline"></i> Nieuw
                    </span>
                </li>
            {% else %}
                <li class="page-item">
                    <a class="page-link" href="/web/activities?sort=new">
                        <i class="fa fa-asterisk d-none d-sm-inline"></i> Nieuw
                    </a>
                </li>
            {% endif %}
            {% if sort == "upcoming" %}
                <li class="page-item active">
                    <span class="page-link">
                        <i class="fa fa-calendar d-none d-sm-inline"></i> Binnenkort
                    </span>
                </li>
            {% else %}
                <li class="page-item">
                    <a class="page-link" href="/web/activities?sort=upcoming">
                        <i class="fa fa-calendar d-none d-sm-inline"></i> Binnenkort
                    </a>
                </li>
            {% endif %}
            {% if sort == "near-me" %}
                <li class="page-item active">
                    <span class="page-link">
                        <i class="fa fa-map-marker d-none d-sm-inline"></i> Dichtbij
                    </span>
                </li>
            {% else %}
                <li class="page-item">
                    <a class="page-link" href="/web/activities?sort=near-me">
                        <i class="fa fa-map-marker d-none d-sm-inline"></i> Dichtbij
                    </a>
                </li>
            {% endif %}
        </ul>
        <!-- View options, only visible in md and above -->
        <ul class="pagination d-none d-md-flex">
            <li class="page-item">
                <a class="page-link" href="/web/activities?view=grid">
                    <i class="fa fa-th-large"></i> Raster
                </a>
            </li>
            <li class="page-item active">
                <span class="page-link">
                    <i class="fa fa-list"></i> Lijst
                </span>
            </li>
        </ul>
    </div>
    <!-- Title -->
    {% if sort == "new" %}
        <h2>Nieuwste spellen</h2>
    {% elif sort == "upcoming" %}
        <h2>Binnenkort op de agenda</h2>
    {% elif sort == "near-me" %}
        <h2>In mijn buurt</h2>
    {% endif %}
    <!-- Link to user activities -->
    {% if base.user %}
        <div class="alert alert-info">
            Spellen die je zelf organiseert worden niet getoond op deze pagina.
            Deze spellen zijn te vinden in je persoonlijk menu, onder <a class="alert-link" href="/web/user/activities">Mijn spellen</a>.
        </div>
    {% endif %}
    <!-- Check if a location is set when showing activities near the user -->
    {% if sort == "near-me" and not base.user.location %}
        <div class="alert alert-warning">
            {% if base.user %}
                Om deze functie te activeren moet je een adres ingeven bij <a class="alert-link" href="/web/user/settings">Instellingen</a>.
            {% else %}
                Om deze functie te activeren moet je eerst <a class="alert-link" href="/authentication/welcome?redirect=%2Fweb%2Factivities">aanmelden</a>.
                Daarna kan je een adres ingeven bij <a class="alert-link" href="/web/user/settings">Instellingen</a>.
            {% endif %}
        </div>
    <!-- Activities -->
    {% elif activities %}
        {% for activity in activities %}
            <a class="{% if activity.availableSeats == 0 %} red {% elif activity.availableSeats == 1 %} yellow {% else %} green {% endif %} autoborder item"
                href="/web/activity/{{ activity.id }}">
                <!-- Separate image sizing for xs, sm and md -->
                <img class="d-sm-none align-self-start" width="75" src="{{ activity.thumbnail }}">
                <img class="d-none d-sm-flex d-md-none align-self-start" width="150" src="{{ activity.picture }}">
                <img class="d-none d-md-flex align-self-start" width="200" src="{{ activity.picture }}">
                <div class="body">
                    <h5>{{ activity.name }}</h5>
                    <p>
                        <i class="fa fa-calendar"></i>
                        <!-- xs shows abbreviated weekday -->
                        <span class="d-sm-none">{{ activity.shortDate }}</span>
                        <!-- sm shows the full weekday -->
                        <span class="d-none d-sm-inline">{{ activity.longDate }}</span>
                        <!-- md adds the time -->
                        <span class="d-none d-md-inline">om {{ activity.time }}</span>
                        <br>
                        <!-- Show the time separately in xs and sm -->
                        <span class="d-md-none">
                            <i class="fa fa-clock-o"></i> {{ activity.time }}<br>
                        </span>
                        <i class="fa fa-user"></i> {{ activity.host.name }}<br>
                        <i class="fa fa-map-marker"></i> {{ activity.location.city }}
                        {% if base.user.location %}
                            ({{ activity.distance }}km)
                        {% endif %}
                    </p>
                </div>
            </a>
        {% endfor %}
    <!-- Placeholder -->
    {% else %}
        <p>Geen spellen gepland.</p>
    {% endif %}
        </div>
        <!-- Footer -->
        <footer class="container py-3 text-center">
            © 2018 - Rond De Tafel<br>
            Like ons op <a href="https://www.facebook.com/ronddetafel.be" target="_blank">Facebook</a> <i class="fa fa-facebook-official"></i><br>
            Broncode beschikbaar op <a href="https://github.com/svanimpe/around-the-table.git" target="_blank">GitHub</a> <i class="fa fa-github"></i>
        </footer>
        <!-- Scripts -->
        <script src="/public/js/popper.min.js"></script>
        <script src="/public/js/bootstrap.min.js"></script>
        <script>
            // Set the href for the sign in link.
            var redirect = window.location.pathname;
            $(".global-signin").attr("href", "/authentication/welcome?redirect=" + encodeURIComponent(redirect));
        </script>
        {% block additional-body %}{% endblock %}
    </body>
    </html>
    <!DOCTYPE html>
    <html lang="nl">
    <head>
        <title>{% block title %}Rond De Tafel
            {% if sort == "new" %}
                {{ block.super }} - Nieuwste spellen
            {% elif sort == "upcoming" %}
                {{ block.super }} - Binnenkort op de agenda
            {% elif sort == "near-me" %}
                {{ block.super }} - In mijn buurt
            {% endif %}
        {% endblock %}</title>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
        <meta name="author" content="Steven Van Impe">
        <meta name="description" content="Rond De Tafel brengt mensen en spellen samen. Vind spellen, zoek medespelers en maak nieuwe vrienden.">
        <meta property="og:site_name" content="Rond De Tafel">
        <meta property="og:type" content="website">
        <meta property="fb:app_id" content="{{ base.facebook.app }}">
        <meta property="og:description" content="Rond De Tafel brengt mensen en spellen samen. Vind spellen, zoek medespelers en maak nieuwe vrienden.">
        <meta property="og:url" content="{{ base.opengraph.url }}">
        {% block opengraph %}
            <meta property="og:title" content="Rond De tafel">
            <meta property="og:image" content="{{ base.opengraph.image }}">
        {% endblock %}
        <link href="/public/img/favicon.png" rel="icon" type="image/png">
        <link href="/public/css/bootstrap.min.css" rel="stylesheet">
        <link href="/public/css/font-awesome.min.css" rel="stylesheet">
        <link href="/public/css/pikaday.min.css" rel="stylesheet">
        <style>
            .navbar, .btn-primary {
                background-color: #2185D0;
            }
            h2, h3 {
                margin-bottom: 1rem;
            }
            img.avatar {
                width: 40px;
                height: 40px;
            }
            /* Pagination, used for sort and view options. */
            .page-link {
                color: #2185D0;
            }
            .page-item.active .page-link {
                background-color: #2185D0;
                border-color: #2185D0;
            }
            /* Activity cards, used in grid view. */
            a.card {
                width: 100%;
                color: inherit;
                text-decoration: none;
            }
            a.card.green {
                box-shadow: 0 1px 0 0 #21BA45;
            }
            a.card.yellow {
                box-shadow: 0 1px 0 0 #FBBD08;
            }
            a.card.red {
                box-shadow: 0 1px 0 0 #DB2828;
            }
            a.card .card-body {
                line-height: 2em;
            }
            /* Activity items, used in list view. */
            a.item {
                display: flex;
                color: inherit;
                text-decoration: none;
                border-radius: 0.25rem;
                margin-bottom: 1rem;
            }
            a.item:focus, a.item:hover {
                background-color: #f8f9fa;
            }
            a.item.green {
                box-shadow: 1px 0 0 0 #21BA45;
            }
            a.item.yellow {
                box-shadow: 1px 0 0 0 #FBBD08;
            }
            a.item.red {
                box-shadow: 1px 0 0 0 #DB2828;
            }
            a.item .body {
                display: flex;
                flex-direction: column;
                margin-left: 1rem;
                line-height: 2em;
            }
            @media(min-width:768px) {
                a.item.autoborder {
                    border: 1px solid rgba(0, 0, 0, 0.125);
                }
                a.item.autoborder .body {
                    margin-top: 0.5rem;
                }
            }
            /* Conversations and messages */
            a.conversation {
                display: flex;
                color: inherit;
                text-decoration: none;
            }
            a.conversation .body {
                display: flex;
                flex-direction: column;
                margin-left: 1rem;
            }
            @media(min-width:768px) {
                .messages {
                    margin-left: 2rem;
                }
            }
            /* Margins for icons */
            .fa-calendar, .fa-clock-o, .fa-envelope, .fa-hourglass-o, .fa-map-marker, .fa-user, .fa-users {
                margin-right: 0.25rem;
            }
            .fa-home {
                margin-left: 0.25rem;
            }
            /* Don't use margins in input groups or buttons */
            button > i.fa, .input-group-text > i.fa {
                margin-right: 0;
            }
            .fa-facebook-official {
                color: #29487d;
            }
        </style>
        <!-- jQuery is included in head because it's used by included components in body. -->
        <script src="/public/js/jquery.min.js"></script>
        {% block additional-head %}{% endblock %}
    </head>
    <body>
        <!-- Collapsed navbar -->
        <nav class="d-md-none navbar navbar-dark">
            <a class="navbar-brand" href="/web/home">Rond De Tafel</a>
            <ul class="navbar-nav ml-auto mr-3">
                {% if base.unreadMessageCount > 0 %}
                    <li class="nav-item">
                        <a class="nav-link" href="/web/user/messages">
                            <i class="fa fa-envelope"></i>
                        </a>
                    </li>
                {% endif %}
            </ul>
            <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarResponsive">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarResponsive">
                <ul class="navbar-nav">
                    <li class="nav-item">
                        <a class="nav-link" href="/web/activities">Spellen</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="/web/host">Organiseer</a>
                    </li>
                    {% if base.user %}
                        <li class="nav-item">
                            <a class="nav-link" href="/web/user/activities">Mijn spellen</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="/web/user/messages">
                                Berichten
                                {% if base.unreadMessageCount > 0 %}
                                    ({{ base.unreadMessageCount }})
                                {% endif %}
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="/web/user/settings">Instellingen</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="/authentication/signout">Afmelden</a>
                        </li>
                    {% else %}
                        <li class="nav-item">
                            <!-- The href will be set in code -->
                            <a class="global-signin nav-link" href="#">Aanmelden</a>
                        </li>
                    {% endif %}
                    <li class="nav-item">
                        <a class="nav-link" href="/web/faq">Help</a>
                    </li>
                </ul>
            </div>
        </nav>
        <!-- Full navbar -->
        <nav class="d-none d-md-flex navbar navbar-expand navbar-dark">
            <a class="navbar-brand" href="/web/home">Rond De Tafel</a>
            <ul class="navbar-nav mr-auto">
                <li class="nav-item">
                    <a class="nav-link" href="/web/activities">Spellen</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="/web/host">Organiseer</a>
                </li>
            </ul>
            <ul class="navbar-nav">
                {% if base.user %}
                    {% if base.unreadMessageCount > 0 %}
                        <li class="nav-item">
                            <a class="nav-link" href="/web/user/messages">
                                <i class="fa fa-envelope"></i>
                            </a>
                        </li>
                    {% endif %}
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" data-toggle="dropdown">
                            {{ base.user.name }}
                        </a>
                        <div class="dropdown-menu dropdown-menu-right">
                            <a class="dropdown-item" href="/web/user/activities">Mijn spellen</a>
                            <a class="dropdown-item" href="/web/user/messages">
                                Berichten
                                {% if base.unreadMessageCount > 0 %}
                                    ({{ base.unreadMessageCount }})
                                {% endif %}
                            </a>
                            <a class="dropdown-item" href="/web/user/settings">Instellingen</a>
                            <a class="dropdown-item" href="/authentication/signout">Afmelden</a>
                        </div>
                    </li>
                {% else %}
                    <li class="nav-item">
                        <!-- The href will be set in code -->
                        <a class="global-signin nav-link" href="#">Aanmelden</a>
                    </li>
                {% endif %}
                <li class="nav-item">
                    <a class="nav-link" href="/web/faq">
                        <i class="fa fa-question-circle fa-lg"></i>
                    </a>
                </li>
            </ul>
        </nav>
        <!-- Main content -->
        <div class="container mt-3">
    <div class="d-flex justify-content-center">
        <!-- Sort options -->
        <ul class="pagination mr-md-5">
            {% if sort == "new" %}
                <li class="page-item active">
                    <span class="page-link">
                        <i class="fa fa-asterisk d-none d-sm-inline"></i> Nieuw
                    </span>
                </li>
            {% else %}
                <li class="page-item">
                    <a class="page-link" href="/web/activities?sort=new">
                        <i class="fa fa-asterisk d-none d-sm-inline"></i> Nieuw
                    </a>
                </li>
            {% endif %}
            {% if sort == "upcoming" %}
                <li class="page-item active">
                    <span class="page-link">
                        <i class="fa fa-calendar d-none d-sm-inline"></i> Binnenkort
                    </span>
                </li>
            {% else %}
                <li class="page-item">
                    <a class="page-link" href="/web/activities?sort=upcoming">
                        <i class="fa fa-calendar d-none d-sm-inline"></i> Binnenkort
                    </a>
                </li>
            {% endif %}
            {% if sort == "near-me" %}
                <li class="page-item active">
                    <span class="page-link">
                        <i class="fa fa-map-marker d-none d-sm-inline"></i> Dichtbij
                    </span>
                </li>
            {% else %}
                <li class="page-item">
                    <a class="page-link" href="/web/activities?sort=near-me">
                        <i class="fa fa-map-marker d-none d-sm-inline"></i> Dichtbij
                    </a>
                </li>
            {% endif %}
        </ul>
        <!-- View options, only visible in md and above -->
        <ul class="pagination d-none d-md-flex">
            <li class="page-item">
                <a class="page-link" href="/web/activities?view=grid">
                    <i class="fa fa-th-large"></i> Raster
                </a>
            </li>
            <li class="page-item active">
                <span class="page-link">
                    <i class="fa fa-list"></i> Lijst
                </span>
            </li>
        </ul>
    </div>
    <!-- Title -->
    {% if sort == "new" %}
        <h2>Nieuwste spellen</h2>
    {% elif sort == "upcoming" %}
        <h2>Binnenkort op de agenda</h2>
    {% elif sort == "near-me" %}
        <h2>In mijn buurt</h2>
    {% endif %}
    <!-- Link to user activities -->
    {% if base.user %}
        <div class="alert alert-info">
            Spellen die je zelf organiseert worden niet getoond op deze pagina.
            Deze spellen zijn te vinden in je persoonlijk menu, onder <a class="alert-link" href="/web/user/activities">Mijn spellen</a>.
        </div>
    {% endif %}
    <!-- Check if a location is set when showing activities near the user -->
    {% if sort == "near-me" and not base.user.location %}
        <div class="alert alert-warning">
            {% if base.user %}
                Om deze functie te activeren moet je een adres ingeven bij <a class="alert-link" href="/web/user/settings">Instellingen</a>.
            {% else %}
                Om deze functie te activeren moet je eerst <a class="alert-link" href="/authentication/welcome?redirect=%2Fweb%2Factivities">aanmelden</a>.
                Daarna kan je een adres ingeven bij <a class="alert-link" href="/web/user/settings">Instellingen</a>.
            {% endif %}
        </div>
    <!-- Activities -->
    {% elif activities %}
        {% for activity in activities %}
            <a class="{% if activity.availableSeats == 0 %} red {% elif activity.availableSeats == 1 %} yellow {% else %} green {% endif %} autoborder item"
                href="/web/activity/{{ activity.id }}">
                <!-- Separate image sizing for xs, sm and md -->
                <img class="d-sm-none align-self-start" width="75" src="{{ activity.thumbnail }}">
                <img class="d-none d-sm-flex d-md-none align-self-start" width="150" src="{{ activity.picture }}">
                <img class="d-none d-md-flex align-self-start" width="200" src="{{ activity.picture }}">
                <div class="body">
                    <h5>{{ activity.name }}</h5>
                    <p>
                        <i class="fa fa-calendar"></i>
                        <!-- xs shows abbreviated weekday -->
                        <span class="d-sm-none">{{ activity.shortDate }}</span>
                        <!-- sm shows the full weekday -->
                        <span class="d-none d-sm-inline">{{ activity.longDate }}</span>
                        <!-- md adds the time -->
                        <span class="d-none d-md-inline">om {{ activity.time }}</span>
                        <br>
                        <!-- Show the time separately in xs and sm -->
                        <span class="d-md-none">
                            <i class="fa fa-clock-o"></i> {{ activity.time }}<br>
                        </span>
                        <i class="fa fa-user"></i> {{ activity.host.name }}<br>
                        <i class="fa fa-map-marker"></i> {{ activity.location.city }}
                        {% if base.user.location %}
                            ({{ activity.distance }}km)
                        {% endif %}
                    </p>
                </div>
            </a>
        {% endfor %}
    <!-- Placeholder -->
    {% else %}
        <p>Geen spellen gepland.</p>
    {% endif %}
        </div>
        <!-- Footer -->
        <footer class="container py-3 text-center">
            © 2018 - Rond De Tafel<br>
            Like ons op <a href="https://www.facebook.com/ronddetafel.be" target="_blank">Facebook</a> <i class="fa fa-facebook-official"></i><br>
            Broncode beschikbaar op <a href="https://github.com/svanimpe/around-the-table.git" target="_blank">GitHub</a> <i class="fa fa-github"></i>
        </footer>
        <!-- Scripts -->
        <script src="/public/js/popper.min.js"></script>
        <script src="/public/js/bootstrap.min.js"></script>
        <script>
            // Set the href for the sign in link.
            var redirect = window.location.pathname;
            $(".global-signin").attr("href", "/authentication/welcome?redirect=" + encodeURIComponent(redirect));
        </script>
        {% block additional-body %}{% endblock %}
    </body>
    </html>
    <!DOCTYPE html>
    <html lang="nl">
    <head>
        <title>{% block title %}Rond De Tafel
            {% if sort == "new" %}
                {{ block.super }} - Nieuwste spellen
            {% elif sort == "upcoming" %}
                {{ block.super }} - Binnenkort op de agenda
            {% elif sort == "near-me" %}
                {{ block.super }} - In mijn buurt
            {% endif %}
        {% endblock %}</title>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
        <meta name="author" content="Steven Van Impe">
        <meta name="description" content="Rond De Tafel brengt mensen en spellen samen. Vind spellen, zoek medespelers en maak nieuwe vrienden.">
        <meta property="og:site_name" content="Rond De Tafel">
        <meta property="og:type" content="website">
        <meta property="fb:app_id" content="{{ base.facebook.app }}">
        <meta property="og:description" content="Rond De Tafel brengt mensen en spellen samen. Vind spellen, zoek medespelers en maak nieuwe vrienden.">
        <meta property="og:url" content="{{ base.opengraph.url }}">
        {% block opengraph %}
            <meta property="og:title" content="Rond De tafel">
            <meta property="og:image" content="{{ base.opengraph.image }}">
        {% endblock %}
        <link href="/public/img/favicon.png" rel="icon" type="image/png">
        <link href="/public/css/bootstrap.min.css" rel="stylesheet">
        <link href="/public/css/font-awesome.min.css" rel="stylesheet">
        <link href="/public/css/pikaday.min.css" rel="stylesheet">
        <style>
            .navbar, .btn-primary {
                background-color: #2185D0;
            }
            h2, h3 {
                margin-bottom: 1rem;
            }
            img.avatar {
                width: 40px;
                height: 40px;
            }
            /* Pagination, used for sort and view options. */
            .page-link {
                color: #2185D0;
            }
            .page-item.active .page-link {
                background-color: #2185D0;
                border-color: #2185D0;
            }
            /* Activity cards, used in grid view. */
            a.card {
                width: 100%;
                color: inherit;
                text-decoration: none;
            }
            a.card.green {
                box-shadow: 0 1px 0 0 #21BA45;
            }
            a.card.yellow {
                box-shadow: 0 1px 0 0 #FBBD08;
            }
            a.card.red {
                box-shadow: 0 1px 0 0 #DB2828;
            }
            a.card .card-body {
                line-height: 2em;
            }
            /* Activity items, used in list view. */
            a.item {
                display: flex;
                color: inherit;
                text-decoration: none;
                border-radius: 0.25rem;
                margin-bottom: 1rem;
            }
            a.item:focus, a.item:hover {
                background-color: #f8f9fa;
            }
            a.item.green {
                box-shadow: 1px 0 0 0 #21BA45;
            }
            a.item.yellow {
                box-shadow: 1px 0 0 0 #FBBD08;
            }
            a.item.red {
                box-shadow: 1px 0 0 0 #DB2828;
            }
            a.item .body {
                display: flex;
                flex-direction: column;
                margin-left: 1rem;
                line-height: 2em;
            }
            @media(min-width:768px) {
                a.item.autoborder {
                    border: 1px solid rgba(0, 0, 0, 0.125);
                }
                a.item.autoborder .body {
                    margin-top: 0.5rem;
                }
            }
            /* Conversations and messages */
            a.conversation {
                display: flex;
                color: inherit;
                text-decoration: none;
            }
            a.conversation .body {
                display: flex;
                flex-direction: column;
                margin-left: 1rem;
            }
            @media(min-width:768px) {
                .messages {
                    margin-left: 2rem;
                }
            }
            /* Margins for icons */
            .fa-calendar, .fa-clock-o, .fa-envelope, .fa-hourglass-o, .fa-map-marker, .fa-user, .fa-users {
                margin-right: 0.25rem;
            }
            .fa-home {
                margin-left: 0.25rem;
            }
            /* Don't use margins in input groups or buttons */
            button > i.fa, .input-group-text > i.fa {
                margin-right: 0;
            }
            .fa-facebook-official {
                color: #29487d;
            }
        </style>
        <!-- jQuery is included in head because it's used by included components in body. -->
        <script src="/public/js/jquery.min.js"></script>
        {% block additional-head %}{% endblock %}
    </head>
    <body>
        <!-- Collapsed navbar -->
        <nav class="d-md-none navbar navbar-dark">
            <a class="navbar-brand" href="/web/home">Rond De Tafel</a>
            <ul class="navbar-nav ml-auto mr-3">
                {% if base.unreadMessageCount > 0 %}
                    <li class="nav-item">
                        <a class="nav-link" href="/web/user/messages">
                            <i class="fa fa-envelope"></i>
                        </a>
                    </li>
                {% endif %}
            </ul>
            <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarResponsive">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarResponsive">
                <ul class="navbar-nav">
                    <li class="nav-item">
                        <a class="nav-link" href="/web/activities">Spellen</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="/web/host">Organiseer</a>
                    </li>
                    {% if base.user %}
                        <li class="nav-item">
                            <a class="nav-link" href="/web/user/activities">Mijn spellen</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="/web/user/messages">
                                Berichten
                                {% if base.unreadMessageCount > 0 %}
                                    ({{ base.unreadMessageCount }})
                                {% endif %}
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="/web/user/settings">Instellingen</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="/authentication/signout">Afmelden</a>
                        </li>
                    {% else %}
                        <li class="nav-item">
                            <!-- The href will be set in code -->
                            <a class="global-signin nav-link" href="#">Aanmelden</a>
                        </li>
                    {% endif %}
                    <li class="nav-item">
                        <a class="nav-link" href="/web/faq">Help</a>
                    </li>
                </ul>
            </div>
        </nav>
        <!-- Full navbar -->
        <nav class="d-none d-md-flex navbar navbar-expand navbar-dark">
            <a class="navbar-brand" href="/web/home">Rond De Tafel</a>
            <ul class="navbar-nav mr-auto">
                <li class="nav-item">
                    <a class="nav-link" href="/web/activities">Spellen</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="/web/host">Organiseer</a>
                </li>
            </ul>
            <ul class="navbar-nav">
                {% if base.user %}
                    {% if base.unreadMessageCount > 0 %}
                        <li class="nav-item">
                            <a class="nav-link" href="/web/user/messages">
                                <i class="fa fa-envelope"></i>
                            </a>
                        </li>
                    {% endif %}
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" data-toggle="dropdown">
                            {{ base.user.name }}
                        </a>
                        <div class="dropdown-menu dropdown-menu-right">
                            <a class="dropdown-item" href="/web/user/activities">Mijn spellen</a>
                            <a class="dropdown-item" href="/web/user/messages">
                                Berichten
                                {% if base.unreadMessageCount > 0 %}
                                    ({{ base.unreadMessageCount }})
                                {% endif %}
                            </a>
                            <a class="dropdown-item" href="/web/user/settings">Instellingen</a>
                            <a class="dropdown-item" href="/authentication/signout">Afmelden</a>
                        </div>
                    </li>
                {% else %}
                    <li class="nav-item">
                        <!-- The href will be set in code -->
                        <a class="global-signin nav-link" href="#">Aanmelden</a>
                    </li>
                {% endif %}
                <li class="nav-item">
                    <a class="nav-link" href="/web/faq">
                        <i class="fa fa-question-circle fa-lg"></i>
                    </a>
                </li>
            </ul>
        </nav>
        <!-- Main content -->
        <div class="container mt-3">
    <div class="d-flex justify-content-center">
        <!-- Sort options -->
        <ul class="pagination mr-md-5">
            {% if sort == "new" %}
                <li class="page-item active">
                    <span class="page-link">
                        <i class="fa fa-asterisk d-none d-sm-inline"></i> Nieuw
                    </span>
                </li>
            {% else %}
                <li class="page-item">
                    <a class="page-link" href="/web/activities?sort=new">
                        <i class="fa fa-asterisk d-none d-sm-inline"></i> Nieuw
                    </a>
                </li>
            {% endif %}
            {% if sort == "upcoming" %}
                <li class="page-item active">
                    <span class="page-link">
                        <i class="fa fa-calendar d-none d-sm-inline"></i> Binnenkort
                    </span>
                </li>
            {% else %}
                <li class="page-item">
                    <a class="page-link" href="/web/activities?sort=upcoming">
                        <i class="fa fa-calendar d-none d-sm-inline"></i> Binnenkort
                    </a>
                </li>
            {% endif %}
            {% if sort == "near-me" %}
                <li class="page-item active">
                    <span class="page-link">
                        <i class="fa fa-map-marker d-none d-sm-inline"></i> Dichtbij
                    </span>
                </li>
            {% else %}
                <li class="page-item">
                    <a class="page-link" href="/web/activities?sort=near-me">
                        <i class="fa fa-map-marker d-none d-sm-inline"></i> Dichtbij
                    </a>
                </li>
            {% endif %}
        </ul>
        <!-- View options, only visible in md and above -->
        <ul class="pagination d-none d-md-flex">
            <li class="page-item">
                <a class="page-link" href="/web/activities?view=grid">
                    <i class="fa fa-th-large"></i> Raster
                </a>
            </li>
            <li class="page-item active">
                <span class="page-link">
                    <i class="fa fa-list"></i> Lijst
                </span>
            </li>
        </ul>
    </div>
    <!-- Title -->
    {% if sort == "new" %}
        <h2>Nieuwste spellen</h2>
    {% elif sort == "upcoming" %}
        <h2>Binnenkort op de agenda</h2>
    {% elif sort == "near-me" %}
        <h2>In mijn buurt</h2>
    {% endif %}
    <!-- Link to user activities -->
    {% if base.user %}
        <div class="alert alert-info">
            Spellen die je zelf organiseert worden niet getoond op deze pagina.
            Deze spellen zijn te vinden in je persoonlijk menu, onder <a class="alert-link" href="/web/user/activities">Mijn spellen</a>.
        </div>
    {% endif %}
    <!-- Check if a location is set when showing activities near the user -->
    {% if sort == "near-me" and not base.user.location %}
        <div class="alert alert-warning">
            {% if base.user %}
                Om deze functie te activeren moet je een adres ingeven bij <a class="alert-link" href="/web/user/settings">Instellingen</a>.
            {% else %}
                Om deze functie te activeren moet je eerst <a class="alert-link" href="/authentication/welcome?redirect=%2Fweb%2Factivities">aanmelden</a>.
                Daarna kan je een adres ingeven bij <a class="alert-link" href="/web/user/settings">Instellingen</a>.
            {% endif %}
        </div>
    <!-- Activities -->
    {% elif activities %}
        {% for activity in activities %}
            <a class="{% if activity.availableSeats == 0 %} red {% elif activity.availableSeats == 1 %} yellow {% else %} green {% endif %} autoborder item"
                href="/web/activity/{{ activity.id }}">
                <!-- Separate image sizing for xs, sm and md -->
                <img class="d-sm-none align-self-start" width="75" src="{{ activity.thumbnail }}">
                <img class="d-none d-sm-flex d-md-none align-self-start" width="150" src="{{ activity.picture }}">
                <img class="d-none d-md-flex align-self-start" width="200" src="{{ activity.picture }}">
                <div class="body">
                    <h5>{{ activity.name }}</h5>
                    <p>
                        <i class="fa fa-calendar"></i>
                        <!-- xs shows abbreviated weekday -->
                        <span class="d-sm-none">{{ activity.shortDate }}</span>
                        <!-- sm shows the full weekday -->
                        <span class="d-none d-sm-inline">{{ activity.longDate }}</span>
                        <!-- md adds the time -->
                        <span class="d-none d-md-inline">om {{ activity.time }}</span>
                        <br>
                        <!-- Show the time separately in xs and sm -->
                        <span class="d-md-none">
                            <i class="fa fa-clock-o"></i> {{ activity.time }}<br>
                        </span>
                        <i class="fa fa-user"></i> {{ activity.host.name }}<br>
                        <i class="fa fa-map-marker"></i> {{ activity.location.city }}
                        {% if base.user.location %}
                            ({{ activity.distance }}km)
                        {% endif %}
                    </p>
                </div>
            </a>
        {% endfor %}
    <!-- Placeholder -->
    {% else %}
        <p>Geen spellen gepland.</p>
    {% endif %}
        </div>
        <!-- Footer -->
        <footer class="container py-3 text-center">
            © 2018 - Rond De Tafel<br>
            Like ons op <a href="https://www.facebook.com/ronddetafel.be" target="_blank">Facebook</a> <i class="fa fa-facebook-official"></i><br>
            Broncode beschikbaar op <a href="https://github.com/svanimpe/around-the-table.git" target="_blank">GitHub</a> <i class="fa fa-github"></i>
        </footer>
        <!-- Scripts -->
        <script src="/public/js/popper.min.js"></script>
        <script src="/public/js/bootstrap.min.js"></script>
        <script>
            // Set the href for the sign in link.
            var redirect = window.location.pathname;
            $(".global-signin").attr("href", "/authentication/welcome?redirect=" + encodeURIComponent(redirect));
        </script>
        {% block additional-body %}{% endblock %}
    </body>
    </html>
    """
}
