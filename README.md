# Polo

Minimalist REST client for JSON APIs. Run it from your browser!

https://github.com/readyforproduction/polo/assets/453736/bfc10c27-018e-4bb4-b4ac-331b173debdf

## How to Use

Please install Docker, then follow these steps:

```bash
> git clone git@github.com:mssantos/polo.git
> cd polo
> docker compose up --build
```

Now Polo is ready on [http://localhost:4000](http://localhost:4000).

## Exploring the Code

This project is built with [Elixir](https://elixir-lang.org/) and [Phoenix](https://www.phoenixframework.org/). Most
of the functionality is powered by [Phoenix LiveView](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html).

Custom JavaScript is used for the [code editor](https://codemirror.net), though it's kept minimal. While Tailwind is
installed, the styles are primarily written in custom CSS and will remain that way.

## Using collections

Polo supports request collections by using [NimblePublisher](https://github.com/dashbitco/nimble_publisher).
Although Polo is designed to run on a local machine, you can share collections with others using Git.

To do this, follow these steps:

1. Create a new folder in `/priv/collections`. The name of the folder should match the name of your collection;
2. Add a new markdown file to the collection folder. The name of the file will be how the request appears in the collections sidebar;
3. Follow the template below to create a new request:

```markdown
<!--- The JSON represents the request attributes. It must match the `Polo.Client.Request` from the source code. -->
{
    "method": "get",
    "url": "https://animechan.xyz/api/random"
}
---
<!--- This block represents the documentation of the endpoint. You can use Markdown syntax here. -->
This endpoint returns a random quote from anime.
```

You can see some examples in `/priv/collections/polo` directory.

## Contributing

* Use issues for bugs and discussions;
* Submit pull requests for code suggestions;
* Don't be an asshole.

## TODO

Check its [project on GitHub](https://github.com/orgs/readyforproduction/projects/9).

## Who is Polo?

The project is named to honor Polo, the God of the Winds and Messenger of Tupã in Tupi-Guarani mythology.

---

© Ready for Production
