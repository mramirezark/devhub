import { ApolloClient, InMemoryCache, HttpLink, from } from '@apollo/client'
import { onError } from '@apollo/client/link/error'
import { CombinedGraphQLErrors } from '@apollo/client/errors'

const GRAPHQL_ENDPOINT =
  import.meta.env.VITE_GRAPHQL_ENDPOINT ?? 'http://localhost:3000/graphql'

const errorLink = onError(({ error }) => {
  if (CombinedGraphQLErrors.is(error)) {
    for (const graphQLError of error.errors) {
      console.error(`[GraphQL error]: ${graphQLError.message}`, {
        path: graphQLError.path,
        extensions: graphQLError.extensions,
      })
    }
    return
  }

  console.error('[Network error]', error)
})

const httpLink = new HttpLink({
  uri: GRAPHQL_ENDPOINT,
  credentials: 'include',
})

export const apolloClient = new ApolloClient({
  link: from([errorLink, httpLink]),
  cache: new InMemoryCache(),
})

