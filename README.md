# Loop: Ride Sharing Application

## Overview
Loop is a full-stack React Native ride-sharing application designed to provide users with a seamless, efficient transportation experience. The app focuses on simplifying the process of finding, selecting, and booking rides through an intuitive and user-friendly interface.

## Application Architecture

**Infrastructure**

- Authentication: Clerk
- Payment Processing: Stripe
- Geolocation: Google Maps
- Messaging: Firebase Cloud Messaging

### Screens (15 Total)

#### 1. Splash Screen
- **Type**: Animated introduction screen
- **Purpose**: Initial app launch experience
- **Key Features**:
  - Animated logo or branding elements
  - Smooth transition to onboarding or main app

#### 2. Onboarding Screen
- **Purpose**: Introduce app features and user flow
- **Key Elements**:
  - App value proposition
  - Quick tutorial of key functionalities
  - Skip or proceed options

#### 3. Authentication Screen
- **Authentication Methods**:
  - Traditional email/password creation
  - OAuth integrations (Google)

#### 4. Home Screen
- **Primary Functions**:
  - Quick ride booking
  - Recent ride history
  - Saved locations
  - User notifications

#### 5. Ride-Finding Screen
- **Core Functionality**:
  - Input origin and destination locations
  - Real-time route mapping
  - Estimated travel time and distance
  - Available ride options

#### 6. Choose Rider Screen
- **Features**:
  - List of available drivers
  - Driver profiles and ratings
  - Vehicle information
  - Estimated arrival times
  - Pricing for different ride types

#### 7. Confirm Ride Screen
- **Details**:
  - Ride summary
  - Driver information
  - Estimated time of arrival
  - Pickup and drop-off locations
  - Confirmation button

#### 8. Payment Screen
- **Payment Processing**:
  - Multiple payment method support
  - Fare breakdown
  - Payment confirmation


### Navigation Tabs

#### 1. Home Tab
- Quick access to ride booking
- Recommended routes
- Saved locations

#### 2. Recent Rides Tab
- Ride history
- Past trip details
- Receipts
- Ability to rebook similar rides

#### 3. Messages Tab
- In-app communication with drivers
- Support chat
- Ride-related notifications
- User messaging system

#### 4. Profile Tab
- User account management
- Personal information
- Payment methods
- App settings
- Ride preferences

## Technical Considerations

### Technology Stack
- **Frontend**: React Native
- **State Management**: Zustand
- **Backend**:  (Node.js/Express/Firebase)
- **Database**: NeonDB
- **Authentication**: OAuth, Firebase Auth

### Key Features to Implement
- Real-time geolocation tracking
- Secure payment gateway integration
- Driver and rider rating system
- In-app support and help center
- Ride scheduling
- Price estimation
- Multiple ride type options

## Design Philosophy
- User-centric design
- Intuitive navigation
- Seamless user experience
- Performance optimization
- Accessibility features

## Future Roadmap
- Multi-language support
- Carpooling features
- Corporate/enterprise ride solutions
- Offline mode capabilities
- Advanced analytics for users

## Development Notes
- Ensure robust error handling
- Implement comprehensive testing
- Focus on performance and scalability
- Prioritize user privacy and data security



# Future updates

## Navigation Tabs

#### 1. Home Tab (Updated)
- Quick access to ride booking
- Recommended routes
- Saved locations
- **New Feature: Nearby Rides Feed**
  - Scrollable list of available rides in user's vicinity
  - Real-time ride discovery
  - Location-based ride recommendations
  - Instant ride request capabilities


**Implement Driver Notification System**

- Real-time booking notifications
- Detailed ride request alerts
- Instant rider information
- Acceptance/Decline ride options
- Push notification integration




EXPO_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_test_dG9wLWpvZXktOTkuY2xlcmsuYWNjb3VudHMuZGV2JA
CLERK_SECRET_KEY=sk_test_nJo2MuIH9XyHc6bhlqCbNuatxH2HksN8kGzPsPBr0P

EXPO_PUBLIC_PLACES_API_KEY=      / 2:59:06
EXPO_PUBLIC_DIRECTIONS_API_KEY=

DATABASE_URL=postgresql://neondb_owner:npg_CLP7baM9Uhrm@ep-broad-sea-a48woyzc-pooler.us-east-1.aws.neon.tech/neondb?sslmode=require

EXPO_PUBLIC_SERVER_URL=https://uber.dev/

EXPO_PUBLIC_GEOAPIFY_API_KEY=4469b593c5cc4ec0b9ec455985ed864a

EXPO_PUBLIC_STRIPE_PUBLISHABLE_KEY=
STRIPE_SECRET_KEY=


