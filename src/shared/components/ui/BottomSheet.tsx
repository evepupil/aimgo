import { useCallback, useMemo, type ReactNode } from 'react';
import { StyleSheet } from 'react-native';
import GorhomBottomSheet, { BottomSheetBackdrop } from '@gorhom/bottom-sheet';
import type { BottomSheetDefaultBackdropProps } from '@gorhom/bottom-sheet/lib/typescript/components/bottomSheetBackdrop/types';

type BottomSheetProps = {
  sheetRef: React.RefObject<GorhomBottomSheet | null>;
  snapPoints?: string[];
  children: ReactNode;
  onClose?: () => void;
};

export function BottomSheet({
  sheetRef,
  snapPoints = ['50%', '80%'],
  children,
  onClose,
}: BottomSheetProps) {
  const points = useMemo(() => snapPoints, [snapPoints]);

  const renderBackdrop = useCallback(
    (props: BottomSheetDefaultBackdropProps) => (
      <BottomSheetBackdrop {...props} disappearsOnIndex={-1} appearsOnIndex={0} opacity={0.5} />
    ),
    [],
  );

  return (
    <GorhomBottomSheet
      ref={sheetRef}
      index={-1}
      snapPoints={points}
      enablePanDownToClose
      backdropComponent={renderBackdrop}
      backgroundStyle={styles.background}
      handleIndicatorStyle={styles.indicator}
      onChange={(index) => {
        if (index === -1) onClose?.();
      }}
    >
      {children}
    </GorhomBottomSheet>
  );
}

const styles = StyleSheet.create({
  background: {
    backgroundColor: '#141414',
  },
  indicator: {
    backgroundColor: '#666',
    width: 40,
  },
});
