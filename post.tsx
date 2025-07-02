import { icons } from "@/constants";
import { useUserStore } from "@/store/useUserStore";
import { useUser } from "@clerk/clerk-expo";
import { router } from "expo-router";
import { useState } from "react";
import { ActivityIndicator, Image, TouchableOpacity } from "react-native";

export default function PostRideButton() {
  const { user, isLoaded } = useUser();
  const setDriver = useUserStore((s: { setDriver: any; }) => s.setDriver);
  const [loading, setLoading] = useState(false);

  const handlePress = () => {
    setLoading(true);
    try {
      const isDriver = user?.publicMetadata?.isDriver === true;
      setDriver(isDriver);
      if (isDriver) {
        router.push("/post-ride");
      } else {
        router.push("/verify-driver");
      }
    } catch (e) {
      console.error('Error in PostRideButton:', e);
    } finally {
      setLoading(false);
    }
  };

  return (
    <TouchableOpacity
      disabled={loading || !isLoaded}
      style={{ width: 80, height: 40, borderRadius: 20, backgroundColor: 'black', alignItems: 'center', justifyContent: 'center' }}
      onPress={handlePress}
      activeOpacity={0.8}
    >
      {loading || !isLoaded ? (
        <ActivityIndicator color="#fff" />
      ) : (
        <Image source={icons.plus} style={{ width: 28, height: 28, tintColor: '#fff' }} />
      )}
    </TouchableOpacity>
  );
} 
