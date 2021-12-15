use std::{collections::HashMap, hash::Hash};

pub trait MapCountable<K>
where
    K: Copy,
{
    fn increment(&mut self, key: K) -> ();
    fn min_value(&self) -> i32;
    fn max_value(&self) -> i32;
    fn sorted(&self) -> Vec<(K, i32)>;
}

impl<K: Copy> MapCountable<K> for HashMap<K, i32>
where
    K: Eq + Hash,
{
    fn increment(&mut self, key: K) -> () {
        *self.entry(key).or_insert(0) += 1;
    }

    fn min_value(&self) -> i32 {
        *self.values().min().unwrap_or(&i32::MIN)
    }

    fn max_value(&self) -> i32 {
        *self.values().max().unwrap_or(&i32::MAX)
    }

    fn sorted(&self) -> Vec<(K, i32)> {
        let mut result = self.to_owned().into_iter().collect::<Vec<(K, i32)>>();
        result.sort_by_key(|x| x.1);
        result
    }
}
