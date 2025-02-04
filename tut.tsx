// index.tsx

import { useAuth } from "@clerk/clerk-expo"
import { Redirect } from "expo-router"

const Page = () => {
    const { isSignedIn } = useAuth();

    if (isSignedIn) return <Redirect href = "/(root)/(tabs)/home" />;
    return <Redirect href = "/(auth)/welcome" />
}

import { neon } from '@neondatabase/serverless';

const sql = neon('postgresql://neondb_owner:npg_CLP7baM9Uhrm@ep-broad-sea-a48woyzc-pooler.us-east-1.aws.neon.tech/neondb?sslmode=require');

const posts = await sql('SELECT * FROM posts');

// See https://neon.tech/docs/serverless/serverless-driver
// for more information