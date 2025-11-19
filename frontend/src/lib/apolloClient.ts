import { ApolloClient, InMemoryCache, HttpLink, from } from '@apollo/client'
import { setContext } from '@apollo/client/link/context'
import { onError } from '@apollo/client/link/error'
import { CombinedGraphQLErrors } from '@apollo/client/errors'
import { getStoredAccessToken } from '../features/auth/authSlice'

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

const authLink = setContext((_, { headers }) => {
  const token = getStoredAccessToken()
  return {
    headers: {
      ...headers,
      ...(token && { authorization: `Bearer ${token}` }),
    },
  }
})

const httpLink = new HttpLink({
  uri: GRAPHQL_ENDPOINT,
  credentials: 'include',
})

export const apolloClient = new ApolloClient({
  link: from([authLink, errorLink, httpLink]),
  cache: new InMemoryCache(),
})

