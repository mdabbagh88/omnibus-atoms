#!/bin/bash
if git describe | grep -q -e rc ; then
  echo unstable;
elif support/is_atoms_ee.sh ; then
  echo atoms-ee;
else
  echo atoms-ce;
fi
