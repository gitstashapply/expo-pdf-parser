import { StyleSheet, Text, View } from 'react-native';

import * as ExpoPdfText from 'expo-pdf-text';

export default function App() {
  return (
    <View style={styles.container}>
      <Text>{ExpoPdfText.hello()}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    alignItems: 'center',
    justifyContent: 'center',
  },
});
